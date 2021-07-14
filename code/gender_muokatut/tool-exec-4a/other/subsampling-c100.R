# Lower psi.
# Rscript subsampling.R subnr partyvar fake_indicator penalty
# Example usage:
# Rscript subsampling.R 1 "left" 1 0

csc <- 1

library(distrom)
library(Matrix)
library(tidyverse)
#library(tibble)

# Command line arguments
args           <- commandArgs(trailingOnly=TRUE)

if (length(args) != 5) {
  stop("Feed subnr, partyvar, fake indicator, penalty dummy, Cpar as command line arguments")
}

subnr          <- as.integer(args[1])
partyvar       <- args[2]
fake_indicator <- as.integer(args[3])
penalty        <- as.integer(args[4])
Cpar           <- args[5]

#############################################################################

fcost <- 1e-6

#############################################################################

set.seed(subnr)
nr_cores <- 1

# Environment-specific pathroot
ifelse(csc == 1, pathroot <-  "/home/jernie/", pathroot <- "/Users/jeremiasnieminen/Dropbox/local_speech/")

input  <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
output <- paste0(pathroot, 'analysis/temp/', partyvar, '/inference/')

ifelse(fake_indicator == 1, suffix <- "_randlabels", suffix <- "")

# penalty = 1 -> LASSO on. penalty = 0 -> try only lambda = 0
ifelse(penalty == 1, suffix <- paste0(suffix, ""), suffix <- paste0(suffix, "_nopenalty"))
ifelse(penalty == 1, nrlambda <- 100, nrlambda <- 1)
ifelse(penalty == 1, lstart <- Inf, lstart <- 0)
ifelse(Cpar == "Cadj", suffix <- paste0(suffix, "_Cadj"), suffix <- paste0(suffix, ""))

outfile <- paste0('partisanship-', partyvar, suffix, '_c100-', as.character(subnr), '.csv')

# Use 'randlabel' variable as party variable if fake_indicator = 1
ifelse(fake_indicator == 1, partyvar <- expr(randlabel), partyvar <- partyvar)

sprintf("Using %s as party variable", str(partyvar))
sprintf("Outfile: %s", outfile)

# Load data
ifelse(Cpar == "Cadj", cdata <- "speaker_phrase_counts_bipartisan_adj.rds", cdata <- "speaker_phrase_counts_bipartisan.rds")
ifelse(Cpar == "Cadj", metadata <- "speaker_metadata_data_1_adj.rds", metadata <- "speaker_metadata_data_1.rds")

C                <- readRDS(paste0(input, cdata))
full_data        <- readRDS(paste0(input, metadata))

# Drop if missing party label:
full_data <- full_data[which(full_data[[partyvar]] != ""), ]

C$id <- rownames(C)
C <- subset(C, C$id %in% full_data$id)
C$id <- NULL
# This subsetting is just to double check since prepare-data2.R already does this 

# Keep rows where rowsum(C)>0
rownames(full_data) <- full_data$id
full_data <- full_data[rownames(C), ]

all_speakers <- full_data %>%
  group_by(year) %>%
  count(year)

all_speakers <- all_speakers %>%
  rename(session = year,
  all_speakers = n)
# all_speakers data ready

# Sample 10 percent of data without replacement
newdata <- sample_frac(full_data, 0.2, replace = FALSE)

# Nr of sampled speakers to subsize data:
subsize <- newdata %>%
  group_by(year) %>%
  count(year)

# Rename for later merge:
subsize <- subsize %>%
  rename(session = year)
# subsize data ready

print("Subsample size by year: ")
print(subsize, n = 100)
print("newdata object:")
print(newdata, n = 100)

sprintf("Nrows in orig data %g", nrow(full_data))
sprintf("Nrows in new data %g", nrow(newdata))

speaker_metadata <- newdata

# speaker metadata = subsample ids
sprintf("Count len before restricting to subsample ids: %g", nrow(C))
C$id <- rownames(C)
C <- subset(C, C$id %in% speaker_metadata$id)
C$id <- NULL
sprintf("Count len after restricting to subsample ids: %g", nrow(C))

# Construct penalized estimation inputs
X           <- sparse.model.matrix(
  ~ 0 + year + govparty + female + dialect,
  data = speaker_metadata
)

qx          <- qr(as.matrix(X))
X           <- X[, qx$pivot[1:qx$rank]]
rownames(X) <- speaker_metadata$id
X           <- X[rownames(C), ]

R_session   <- sparse.model.matrix(~ 0 + year, data = speaker_metadata, verbose = FALSE)

R           <- R_session * speaker_metadata[[partyvar]]
colnames(R) <- paste(colnames(R), 'R', sep = '_')
rownames(R) <- speaker_metadata$id
R           <- R[rownames(C), ]

rownames(R_session) <- speaker_metadata$id # 
R_session           <- R_session[rownames(C),]

mu          <- as.matrix(speaker_metadata$mu)
mu          <- log(mu)
rownames(mu)<- speaker_metadata$id

# C matrix does not include 0 rows
mu          <- mu[rownames(C), ]

#sprintf("Starting estimation")

start.time <- Sys.time()
# Estimate penalized MLE
cl <- makeCluster(nr_cores, type = 'FORK') 
fit <- dmr(
  cl = cl,
  verb = 1,
  covars = cbind(X, R),
  counts = C,
  mu = mu,
  free = 1:ncol(X),
  fixedcost = fcost,
  lambda.start = lstart,
  lambda.min.ratio = 1e-5,
  nlambda = nrlambda,
  standardize = F
)

stopCluster(cl)
end.time <- Sys.time()
process.time <- end.time - start.time
sprintf("Processing time for a process with %i cores was %g minutes", nr_cores, process.time)

# coef antaa virheviestin. Korjattu Githubin mukaisella korjauksella lähdekoodiin
# Get coefficients from penalized MLE
coefs   <- coef(fit, k = log(nrow(X)), corrected = F)
coefs_X <- coefs[colnames(X), ]
coefs_R <- coefs[colnames(R), ]

# Incremental utility of each phrase for Republicans in a session
# "Phrase-time-specific party loadings"
phi <- R_session %*% coefs_R

# Compute utility of speech for Democrats and Republicans
utility_dem <- cbind(1, X) %*% rbind(coefs['intercept', ], coefs_X)
utility_rep <- utility_dem + phi

# Compute utility of speech for observed speakers and 
# speaker "clones" with the same speech and covariates but the opposite party.
party_matrix       <- replicate(ncol(C), rowSums(R)) # toistaa 1 tai 0 (eli rep. indicator) J kertaa
party_matrix_clone <- (1 - party_matrix)
utility_real       <- utility_dem + party_matrix * phi
utility_clone      <- utility_dem + party_matrix_clone * phi
utility            <- rbind(utility_real, utility_clone)

# Compute expected posterior that speaker and clone is Republican based on speech.
# Compute rho through the likelihood ratio, not from the q's.
party_ratio        <- rowSums(exp(utility_dem)) / rowSums(exp(utility_rep))
likelihood_ratio   <- party_ratio * exp(phi)
rho                <- likelihood_ratio / (1 + likelihood_ratio)
rho                <- rbind(rho, rho)
q                  <- exp(utility) / rowSums(exp(utility))
expected_posterior <- rowSums(rho * q)

# Indicate Republican/Democrat for speakers and clones
republican <- rowSums(R) > 0
republican <- as.matrix(republican)
republican <- rbind(republican, 1 - republican)
party      <- ifelse(republican, 'R', 'D')

# Indicate session of congress for speakers and clones
session        <- speaker_metadata$year
names(session) <- speaker_metadata$id
session        <- session[rownames(utility_dem)]
session        <- as.matrix(session)
session        <- rbind(session, session)

# Compute partisanship
party_pi <- tapply(expected_posterior, list(party, session), mean) 
pi       <- .5 * (party_pi['R', ] + (1 - party_pi['D', ]))
pi       <- pi[order(as.integer(names(pi)))]
pi       <- data.frame(session = as.integer(names(pi)), pi = pi)

# Make sure all keys are of same type:
pi$session             <- as.factor(pi$session)
subsize$session        <- as.factor(subsize$session)
all_speakers$session   <- as.factor(all_speakers$session)

pi = left_join(pi, subsize, by = 'session')
pi = left_join(pi, all_speakers, by = 'session')

write.csv(pi, file = paste0(output, outfile), row.names = F, quote = F)

sprintf("Process %g completed", subnr)
Sys.time()
