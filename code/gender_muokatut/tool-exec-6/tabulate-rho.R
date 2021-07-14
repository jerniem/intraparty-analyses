# Get top5 partisan phrases on the basis of rho
# Usage: Rscript tabulate-rho.R "left" 0 "c0" "Cadj"

library(dplyr)

csc <- 1

# Environment-specific pathroot
#ifelse(csc == 1, pathroot <- '/scratch/project_2001488/simolasa/remote/', pathroot <- '/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/')
ifelse(csc == 1, pathroot <-  '/scratch/work/k84340/parliamentary-speech/', pathroot <- '/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/')

# Command line arguments
args           <- commandArgs(trailingOnly=TRUE)
partyvar       <- args[1]
fake_indicator <- as.integer(args[2])
covariates     <- args[3]
Cpar           <- args[4]

input   <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
output  <- paste0(pathroot, 'analysis/output/', partyvar, '/')

ifelse(fake_indicator == 1, suffix <- "_randlabels", suffix <- "")
ifelse(Cpar == "Cadj", suffix <- paste0(suffix, "_Cadj"), suffix <- suffix)
suffix <- paste0(suffix, "_", covariates)

# Load objects
rho        <- readRDS(paste0(input, "mean_rho", suffix, ".rds"))

print("Dims rho and q:")
print(dim(rho))
print(colnames(rho)[1:3])

session <- c(1907:1914, 1917, 1919:2018)
#session <- c(1919)
for (val in session) {
    sprintf("Session: %s", val)
    outfilename <- paste0("rho-top5-", val, suffix, ".csv")

    rhos <- rho[which(rho$session == val),]
    rhos$session <- NULL

    print("The following should be a phrase")
    print(colnames(rhos)[1])

    print("The following should not be a phrase")
    print(colnames(rho)[1])
   
    # Transpose:
    a <- t(rhos)
    df <- as.data.frame(a)
    colnames(df) <- "phrase_rho"

    # Make another column for phrase names
    df$phrase <- colnames(rhos)

    # Make sure rho value for an example phrase matches phrase_rho value in df
    stopifnot(rho[which(rho$session == val), "euroop.union"] == df[which(df$phrase == "euroop.union"), "phrase_rho"])

    # Sort df according to rho (descending)
    toprep  <- df[order(-df$phrase_rho),]

    # Top5rep
    top5rep <- toprep[1:5,]
    colnames(top5rep) <- c("phrase_rho","top5_rep")

    # Top5dem
    top5dem  <- tail(toprep, 5)
    # Sort (ascending)
    top5dem  <- top5dem[order(top5dem$phrase_rho),]
    colnames(top5dem) <- c("phrase_rho","top5_dem")

    top5 <- cbind(top5rep, top5dem)
    rownames(top5) <- c()

    print(top5)

    write.csv(top5, file = paste0(output, outfilename), row.names = F, quote = F)
    print(paste0("Output written to: ", output, "rho-top5-", val, suffix, ".csv"))

}









