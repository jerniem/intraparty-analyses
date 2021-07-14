library(dplyr)

csc <- 1

# Environment-specific pathroot
ifelse(csc == 1, pathroot <-  "/home/jernie/", pathroot <- "/Users/jeremiasnieminen/Dropbox/local_speech/")

# Command line arguments
args           <- commandArgs(trailingOnly=TRUE)
nr_datasets    <- as.integer(args[1])
partyvar       <- args[2]
fake_indicator <- as.integer(args[3])
penalty        <- as.integer(args[4])
covariates     <- args[5]
Cpar           <- args[6]

if (length(args) != 6) {
  stop("Feed nr_datasets, partyvar, randlabel indicator, penalty dummy, covariates, Cpar as command line arguments")
}

# Folders
input  <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
output <- paste0(pathroot, 'analysis/output/', partyvar, '/')

ifelse(fake_indicator == 1, suffix <- "_randlabels", suffix <- "")
ifelse(penalty == 0, suffix <- paste0(suffix, "_nopenalty"), suffix <- paste0(suffix, ""))
ifelse(Cpar == "Cadj", suffix <- paste0(suffix, "_Cadj"), suffix <- paste0(suffix, ""))
suffix <- paste0(suffix, "_", covariates)

# File
outfile <- paste0('partisanship-', partyvar, suffix, '.csv')

# Update partyvar for fake case
ifelse(fake_indicator == 1, partyvar <- "randlabel", partyvar <- partyvar)

sprintf("Nr datasets: %g, party variable: %s, fake: %g, outfile name: %s", nr_datasets, partyvar, fake_indicator, outfile)
sprintf("Suffix: %s", suffix)

# Load objects
# utility_dem
# utility_rep
# utility
# phi

speaker_metadata <- readRDS(paste0(input, 'speaker_metadata_bipartisan.rds'))

udemlist <- list()
ureplist <- list()
ulist    <- list()
philist  <- list()

# testing
#for (i in 1:10){
for (i in 1:nr_datasets){

    #utility_dem <- readRDS(paste0(input, 'utility_dem', suffix, '_data_', i, '.rds'))
    utility_dem <- readRDS(paste0(input, 'utility_dem', suffix, '_data_', i))
    #assign(paste("utility_dem", i, sep = ""), utility_dem)
    #print(utility_dem)
    udemlist[[i]] = utility_dem

    #utility_rep <- readRDS(paste0(input, 'utility_rep', suffix, '_data_', i, '.rds'))
    utility_rep <- readRDS(paste0(input, 'utility_rep', suffix, '_data_', i))
    ureplist[[i]] = utility_rep

    #utility <- readRDS(paste0(input, 'utility', suffix, '_data_', i, '.rds'))
    utility <- readRDS(paste0(input, 'utility', suffix, '_data_', i))
    #assign(paste("utility", i, sep = ""), utility)
    ulist[[i]] = utility

    #phi <- readRDS(paste0(input, 'phi', suffix, '_data_', i, '.rds'))
    phi <- readRDS(paste0(input, 'phi', suffix, '_data_', i))
    #assign(paste("phi", i, sep = ""), phi)
    philist[[i]] = phi

}

utility_dem <- do.call(cbind, udemlist)
print("cbind utility dem done")
utility_rep <- do.call(cbind, ureplist)
print("cbind utility rep done")
utility     <- do.call(cbind, ulist)
print("cbind utility done")
phi         <- do.call(cbind, philist)
print("cbind phi done")

#print(colnames(phi))
#print(colnames(utility_rep))
#print(colnames(utility_dem))
#print(colnames(utility))

print(dim(phi))
print(dim(utility_rep))
print(dim(utility_dem))
print(dim(utility))

####### added party fixed effect

# Re-construct R:
R           <- sparse.model.matrix(~ 0 + year + party, data = speaker_metadata)
R           <- R * speaker_metadata[[partyvar]]
colnames(R) <- paste(colnames(R), 'R', sep = '_')
rownames(R) <- speaker_metadata$id
R           <- R[rownames(utility_dem), ]

# Compute expected posterior that speaker and clone is Republican based on speech.
# Compute rho through the likelihood ratio, not from the q's.
party_ratio        <- rowSums(exp(utility_dem)) / rowSums(exp(utility_rep))
likelihood_ratio   <- party_ratio * exp(phi)
rho                <- likelihood_ratio / (1 + likelihood_ratio)
rho                <- rbind(rho, rho)
q                  <- exp(utility) / rowSums(exp(utility))
expected_posterior <- rowSums(rho * q)

# Save objects
saveRDS(rho, file = paste0(input, "rho", suffix, ".rds"))
saveRDS(expected_posterior, file = paste0(input, "expected_posterior", suffix, ".rds"))
saveRDS(likelihood_ratio, file = paste0(input, "likelihood_ratio", suffix, ".rds"))
saveRDS(q, file = paste0(input, "q", suffix, ".rds"))

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

print(sprintf("session rows %d", nrow(session)))
print(sprintf("party rows %d", nrow(party)))
print(sprintf("session cols %d", ncol(session)))
print(sprintf("party cols %d", ncol(party)))

q <- as.matrix(q)
print("converted to matrix")
q <- as.data.frame(q)
print("converted to df")
q$session <- session
q$republican <- party
print("head session:")
head(q$session)
print("head rep:")
head(q$republican)
grouped_q <- q %>% group_by(session, republican)
print("Grouped object constructed")

##### TALLENNUS VÄLISSÄ, TESTI
grouped_q <- grouped_q[complete.cases(grouped_q), ]
#saveRDS(grouped_q, file = paste0(output, "intfileuusi", suffix, ".rds"))
#print("int data saved")
#####

#### base R solution
aggregate(. ~ session + republican, data = grouped_q, mean, na.rm = TRUE)
print("aggregate worked")
####

#### dplyr solution
av_q <- grouped_q %>% summarise_all(mean)
print(head(av_q))
print("Average q constructed")
####

rho <- as.matrix(rho)
print("rho as matrix done")

rho <- as.data.frame(rho)
print("rho as data frame done")

rho$session <- session
print("session saved to rho$session")

av_rho <- rho %>% group_by(session) %>% summarise_all(mean)
print("Average rho constructed")

# Compute partisanship
party_pi <- tapply(expected_posterior, list(party, session), mean)
pi       <- .5 * (party_pi['R', ] + (1 - party_pi['D', ]))
pi       <- pi[order(as.integer(names(pi)))]
pi       <- data.frame(session = as.integer(names(pi)), pi = pi)

# Write files
saveRDS(av_q, file = paste0(input, "mean_q", suffix, ".rds"))
saveRDS(av_rho, file = paste0(input, "mean_rho", suffix, ".rds"))
write.csv(pi, file = paste0(output, outfile), row.names = F, quote = F)
