
# Tabulate top 5 partisan phrases per session per party
# example usage: Rscript tabulate-phrase-partisanship-get-qs.R "left" 1 "c0" "Cadj"
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

input   <- paste0(pathroot, 'analysis/output/', partyvar, '/')
qpath   <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
output  <- paste0(pathroot, 'analysis/output/', partyvar, '/')

ifelse(fake_indicator == 1, suffix <- "_randlabels", suffix <- "")
ifelse(Cpar == "Cadj", suffix <- paste0(suffix, "_Cadj"), suffix <- suffix)
suffix <- paste0(suffix, "_", covariates)

# Load average q for session, party
q <- readRDS(paste0(qpath, "mean_q", suffix, ".rds"))

#print(tbl_df(q[, c("session", "mielipit.pöydällepano")]), n=230)

print("q dimension:")
print(dim(q))
print(colnames(q)[1:4])

get_qs <- function(x, frame) {
  # choose the col named x
  fframe <- frame[x]
  qval  <- fframe[1,1]

  print(x)
  print(qval)
  
  prediction <- round(qval * 100000, digits = 0)

  # Indexing is important below to keep the right output type
  return(prediction[1,1])
}

#session <- c(1907:1914, 1917, 1919:1938,1940:2018)
session <- c(1907:1914, 1917, 1919:2018)
#session <- c(1919)
for (val in session) {
    val <- toString(val)
    print(sprintf("Session: %s", val))

    df <- read.csv(paste0(input, "partisan-phrases-top5-", val, suffix, ".csv"), stringsAsFactors = FALSE)
    print(df[1, "top5_rep"])
    print(class(df[1, "top5_rep"]))
    
    # Choose year-party row of probs data 
    rprobs <- q[which(q$session == val & q$republican == "R"),]
    dprobs <- q[which(q$session == val & q$republican == "D"),]
    
    rprobs$session <- NULL    
    dprobs$session <- NULL
    rprobs$republican <- NULL
    dprobs$republican <- NULL    
 
    print("The following two lines should contain a phrase")
    print(rprobs[1])
    print(dprobs[1])

    df$top5repqr <- lapply(as.vector(df$top5_rep), get_qs, frame = rprobs)
    df$top5repqd <- lapply(as.vector(df$top5_rep), get_qs, frame = dprobs)
    df$top5demqr <- lapply(as.vector(df$top5_dem), get_qs, frame = rprobs)
    df$top5demqd <- lapply(as.vector(df$top5_dem), get_qs, frame = dprobs)

    # Check that q value matching session, party is read into the right place
    stopifnot(q[which(q$session == val & q$republican == "R"), df[1, "top5_rep"]] != df[1, "top5repqr"])
    stopifnot(q[which(q$session == val & q$republican == "D"), df[1, "top5_rep"]] != df[1, "top5repqd"])
    stopifnot(q[which(q$session == val & q$republican == "R"), df[1, "top5_dem"]] != df[1, "top5demqr"])
    stopifnot(q[which(q$session == val & q$republican == "D"), df[1, "top5_dem"]] != df[1, "top5demqd"])

    df <- apply(df,2,as.character)

    print(df)
    write.csv(df, file = paste0(output, "partisan-phrases-q-", val, suffix, ".csv"), row.names = F, quote = F)
    print(paste0("Output written to: ", output, "partisan-phrases-q-", val, suffix, ".csv"))

}



