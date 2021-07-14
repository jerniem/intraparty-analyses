# Get top5 partisan phrases and their indices
# Usage: Rscript tabulate-phrase-partisanship.R "left" 0 "c1" "Cadj" 

library(distrom)
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
zeta        <- readRDS(paste0(input, "phrase_partisanship", suffix, ".rds"))
print(zeta[1:5, 1:5])

session <- zeta$session

#session <- c(1919)
for (val in session) {
    sprintf("Session: %s", val)
    outfilename <- paste0("partisan-phrases-top5-", val, suffix, ".csv")

    # A column vector of zetas
    zetas <- zeta[which(zeta$session == val),]
    zetas$session <- NULL

    print("First five zeta values:")
    print(zetas[1:5])

    print("The following should be a phrase")
    print(colnames(zetas)[1])

    print("The following should not be a phrase")
    print(colnames(zeta)[1])

    # Make a column out of zetas
    #a <- t(as.matrix(zetas))
    a <- t(zetas)
    print(a[1:5,])

    df <- as.data.frame(a)
    print(df[1:5, ])
    colnames(df) <- "phrase_zeta"

    # Make another column for phrase names
    df$phrase <- colnames(zetas)

    #print(zeta[which(zeta$session == val), "tuli.läht"])
    #print(df[which(df$phrase == "tuli.läht"), "phrase_zeta"])
    
    # Make sure zeta value for an example phrase matches phrase_zeta value in df 
    #stopifnot(zeta[which(zeta$session == val), "tuli.läht"] == df[which(df$phrase == "tuli.läht"), "phrase_zeta"])

    # Sort df according to zeta (descending)
    toprep  <- df[order(-df$phrase_zeta),]

    # Highest 5 to top5rep
    top5rep <- toprep[1:5,]
    colnames(top5rep) <- c("phrase_zeta_rep", "top5_rep")

    # Lowest 5 to top5dem
    top5dem  <- tail(toprep, 5)
    # reorder as ascending to get lowest value first
    top5dem  <- top5dem[order(top5dem$phrase_zeta),]
    colnames(top5dem) <- c("phrase_zeta_dem", "top5_dem")

    top5 <- cbind(top5rep, top5dem)
    rownames(top5) <- c()

    #print(top5)
    #print(top5[1, "top5_rep"])
    #print(class(top5[1, "top5_rep"]))

    write.csv(top5, file = paste0(output, outfilename), row.names = F, quote = F)
    print(paste0("Output written to: ", output, "partisan-phrases-top5-", val, suffix, ".csv"))

}



