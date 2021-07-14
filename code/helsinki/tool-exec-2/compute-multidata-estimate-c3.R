# Controls for: govparty, female, first_district

#.libPaths(c("/projappl/project_2001488/project_rpackages", .libPaths()))
#libpath <- .libPaths()[1]

csc <- 1

# Environment-specific pathroot
ifelse(csc == 1, pathroot <-  "/home/jernie/", pathroot <- "/Users/jeremiasnieminen/Dropbox/local_speech/")

# Save the following files:
# utility_dem
# utility_rep
# utility
# phi

set.seed(42)

library(distrom)
library(plyr)

# Command line arguments
args = commandArgs(trailingOnly=TRUE)
nr_cores        <- as.integer(args[1])
curdata         <- args[2]
partyvar        <- args[3]
fake_indicator  <- as.integer(args[4])
penalty         <- as.integer(args[5])
Cpar            <- args[6]

if (length(args) != 6) {
  stop("Feed nr_cores, data name, partyvar, randlabel indicator, penalty dummy, Cpar as command line arguments")
}

sprintf("Data: %s", curdata)
sprintf("Nr cores: %g", nr_cores)

# Folders
input <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
output <- input

# Load objects
ifelse(Cpar == "Cadj", cdata <- paste0(curdata, "_adj.rds"), cdata <- paste0(curdata, ".rds"))

speaker_metadata <- readRDS(paste0(input, 'speaker_metadata_', cdata))
C                <- readRDS(paste0(input, cdata))

lapply(speaker_metadata, class)
#lapply(C, class)

sprintf("Finished loading data")

# Use 'fake' variable as party variable if fake_indicator = 1
ifelse(fake_indicator == 1, partyvar <- "randlabel", partyvar <- partyvar)
ifelse(fake_indicator == 1, suffix <- "_randlabels", suffix <- "")

# penalty = 1 -> LASSO on. penalty = 0 -> try only lambda = 0
ifelse(penalty == 1, suffix <- paste0(suffix, ""), suffix <- paste0(suffix, "nopenalty_"))
ifelse(penalty == 1, nrlambda <- 100, nrlambda <- 1)
ifelse(penalty == 1, lstart <- Inf, lstart <- 0)

ifelse(Cpar == "Cadj", suffix <- paste0(suffix, "_Cadj"), suffix <- paste0(suffix, ""))

sprintf("Using %s as party variable", partyvar)
sprintf("Suffix: %s, nrlambda: %g, lstart: %g", suffix, nrlambda, lstart)

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

rownames(R_session) <- speaker_metadata$id
R_session           <- R_session[rownames(C), ]

mu          <- as.matrix(speaker_metadata$mu)
mu          <- log(mu)
rownames(mu)<- speaker_metadata$id

# (Restricting to rows in C also guarantees data won't include mu = log(0) rows)
mu          <- mu[rownames(C), ]
print(mu)

#print(R)
#print(dim(R))

#mu <- log(rowSums(C))

sprintf("Starting estimation")

start.time <- Sys.time()
# Estimate penalized MLE
cl <- makeCluster(nr_cores, type = 'FORK', outfile = 'log.txt') 
fit <- dmr(
    cl = cl,
    verb = 1,
    covars = cbind(X, R),
    counts = C,
    mu = mu,
    free = 1:ncol(X),
    fixedcost = 1e-5,
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
print(log(nrow(X)))
coefs   <- coef(fit, k = log(nrow(X)), corrected = F)
coefs_X <- coefs[colnames(X), ]
coefs_R <- coefs[colnames(R), ]

# Incremental utility of each phrase for Republicans in a session
# "Phrase-time-specific party loadings"
phi <- R_session %*% coefs_R

# Compute utility of speech for Democrats and Republicans
utility_dem <- cbind(1, X) %*% rbind(coefs['intercept', ], coefs_X)
print(dim(utility_dem))
#print(utility_dem)
#print(coefs['intercept', ])
utility_rep <- utility_dem + phi

# Compute utility of speech for observed speakers and 
# speaker "clones" with the same speech and covariates but the opposite party.
party_matrix       <- replicate(ncol(C), rowSums(R)) # toistaa 1 tai 0 (eli rep. indicator) J kertaa
party_matrix_clone <- (1 - party_matrix)
utility_real       <- utility_dem + party_matrix * phi
utility_clone      <- utility_dem + party_matrix_clone * phi
utility            <- rbind(utility_real, utility_clone)

saveRDS(utility_dem, file = paste0(output, "utility_dem", suffix, "_c3_", curdata))
saveRDS(utility_rep, file = paste0(output, "utility_rep", suffix, "_c3_", curdata))
saveRDS(utility, file = paste0(output, "utility", suffix, "_c3_", curdata))
saveRDS(phi, file = paste0(output, "phi", suffix, "_c3_", curdata))

sprintf("Files for %s, %s written to %s", curdata, partyvar, output)

