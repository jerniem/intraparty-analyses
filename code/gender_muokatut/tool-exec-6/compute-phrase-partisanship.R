# Usage: Rscript compute-phrase-partisanship.R "left" 0 "c0" "Cadj"

library(dplyr)

csc <- 1

# Environment-specific pathroot
ifelse(csc == 1, pathroot <-  '/scratch/work/k84340/parliamentary-speech/', pathroot <- '/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/')

# Command line arguments
args           <- commandArgs(trailingOnly=TRUE)
partyvar       <- args[1]
fake_indicator <- as.integer(args[2])
covariates     <- args[3]
Cpar           <- args[4]

# Folders
input   <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
output <- paste0(pathroot, 'analysis/temp/', partyvar, '/')

ifelse(fake_indicator == 1, suffix <- "_randlabels", suffix <- "")
ifelse(Cpar == "Cadj", suffix <- paste0(suffix, "_Cadj"), suffix <- suffix)
suffix <- paste0(suffix, "_", covariates)

ifelse(Cpar == "Cadj", cdata <- "speaker_phrase_counts_bipartisan_adj.rds", cdata <- "speaker_phrase_counts_bipartisan.rds")

# Load objects
C                <- readRDS(paste0(input, cdata))
speaker_metadata <- readRDS(paste0(input, 'speaker_metadata_bipartisan.rds'))
rho              <- readRDS(paste0(input, 'rho', suffix, '.rds'))
q                <- readRDS(paste0(input, 'q', suffix, '.rds'))

#print(C)
print("C")
print(colnames(C)[1:5])
print(dim(C))

print("rho")
print(colnames(rho)[1:5])
print(dim(rho))

print("q")
print(colnames(q)[1:5])
print(dim(q))

#rho, q
# Product for speakers and clones
product <- q * rho
exc_q   <- 1 - q

#print(rho[1:2,])
#print(product[1:2,])
#print(q[1:2,])
#print(exc_q[1:2,])

print("Computing leaveout")
start.time     <- Sys.time()

rsums <- rowSums(product)
mat_rsums <- matrix(rep(rsums, ncol(C)), ncol = ncol(C))

leaveout <- mat_rsums - product
exc_q <- 1 - q
leaveout_scaled <- leaveout/exc_q 
end.time       <- Sys.time()
process.time <- end.time - start.time

sprintf("Computing leaveout took %g minutes", process.time)

# Since we're gonna take mean over 2 * N_t, multiply nominator by 2
# (0.25 - 0.5 * leaveout -> 0.5 - leaveout)
doublezeta <- 0.5 - leaveout_scaled
doublezeta[1:2,1:2]

print("now computing session")
start.time     <- Sys.time()
session        <- speaker_metadata$year
names(session) <- speaker_metadata$id
session        <- session[rownames(C)]
session        <- as.matrix(session)
session        <- rbind(session, session)
end.time       <- Sys.time()
process.time   <- end.time - start.time

sprintf("computing session took %g minutes", process.time)

print("Got session processed, now comes data framing")

start.time         <- Sys.time()
doublezeta         <- as.matrix(doublezeta)
doublezeta         <- as.data.frame(doublezeta)
doublezeta$session <- session
process.time       <- end.time - start.time
sprintf("data framing took %g minutes", process.time)

print("data framing done, now averaging")

start.time <- Sys.time()
av_zeta <- doublezeta %>% 
  group_by(session) %>% 
  summarise_all(mean)
process.time <- end.time - start.time
sprintf("averaging took %g minutes", process.time)

colnames(av_zeta)[1:5]
av_zeta[1:2,1:2]

print("only saving left")
saveRDS(av_zeta, file = paste0(output, "phrase_partisanship", suffix, ".rds"))

# Construct a yearly data 

sessions <- av_zeta$session

for (val in sessions) {
    # Subset yearly zetas, transpose, sort (descending) and save to temp
    zetas <- av_zeta[which(av_zeta$session == val), ]
    zetas$session <- NULL

    a <- t(as.matrix(zetas))
    b <- as.data.frame(a)

    colnames(b) <- "zeta"
    b$phrase <- colnames(zetas)

    sorted  <- b[order(-b$zeta),]
    saveRDS(sorted, file = paste0(output, "zetas-sorted-", suffix, "-", val, ".rds"))

}


