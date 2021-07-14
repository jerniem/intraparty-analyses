# Adjust C by removing potentially procedural phrases
#
# Example usage: Rscript prepare-data-2b.R "left"
# partyvar only used for input and output data folder
#
# Created March 25, 2020 Salla Simola

#install.packages("distrom", repos="http://cran.r-project.org", lib="/home/jernie/new_env/lib/R/library/")

library(distrom)
library(dplyr)

csc     <- 1
testing <- 0

# Environment-specific pathroot
ifelse(csc == 1, pathroot <- "/home/jernie/", pathroot <- "/Users/jeremiasnieminen/Dropbox/local_speech/")

# Command line arguments
args           <- commandArgs(trailingOnly=TRUE)
partyvar       <- args[1]

input   <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
rulespath   <- paste0(pathroot, 'analysis/input/')
output  <- paste0(pathroot, 'analysis/temp/', partyvar, '/')

######################################################################################
# Read data
ifelse(testing == 1, C <- readRDS(paste0(input, "data_1.rds")), C <- readRDS(paste0(input, "speaker_phrase_counts_bipartisan.rds")))
rules <- read.csv(paste0(rulespath, 'list-adjust-c2.csv'), sep = ";")

print(tail(rules))
print(colnames(rules))

if (testing != 1) {
    C$year       <- NULL
    C$id         <- NULL
    C$speaker_id <- NULL
}

beglen <- length(colnames(C))

print("Nr phrases before dropping any phrases: ")
print(length(colnames(C)))
print("5 first colnames: ")
print(colnames(C)[1:5])

print("5 first rownames: ")
print(rownames(C)[1:5])

######################################################################################
# Functions:

complete_phrase <- function(x) {
  # add regex start and end symbol to get exact matches
  sstring <- paste0("^", x, "$")
  curind  <- grep(sstring, allphrases)
  #print(x)
  #print(curind)
  return(curind)
}

phrase_ends <- function(x) {
  # add regex start and end symbol to get exact matches
  sstring <- paste0(x, "$")
  curind  <- grep(sstring, allphrases)
  #print(x)
  #print(curind)
  return(curind)
}

phrase_begins <- function(x) {
  # add regex start and end symbol to get exact matches
  sstring <- paste0("^", x)
  curind  <- grep(sstring, allphrases)
  #print(x)
  #print(curind)
  return(curind)
}

phrase_includes <- function(x) {
  # add regex start and end symbol to get exact matches
  sstring <- x
  curind  <- grep(sstring, allphrases)
  #print(x)
  #print(curind)
  return(curind)
}

######################################################################################

allphrases <- colnames(C)
exceptions <- rules[which(rules["rule"] == "keep"), "word"]

complete     <- rules[which(rules["rule"] == "complete_phrase"), "word"]
ends         <- rules[which(rules["rule"] == "phrase_ends"), "word"]
starts       <- rules[which(rules["rule"] == "phrase_begins"), "word"]
includes     <- rules[which(rules["rule"] == "phrase_includes"), "word"]

print("### Handling queries with complete phrases ###")
for (query in complete) {
    #print(query)

    # Get all indices
    indices = complete_phrase(query)

    if (length(indices) != 0) {
        print("Matches found for")
       	print(query)
    }

    for (i in indices) {

        # Go back to phrases (safer than removes based on indices)
        phrase = allphrases[i]
       	print(phrase)

        if (phrase %in% exceptions == FALSE) {
            C[phrase] <- NULL
        }
    }
}

print("Nr phrases after dropping completes: ")
print(length(colnames(C)))

print("### Handling 'begins' queries ###")
for (query in starts) {
    #print(query)

    # Get all indices
    indices = phrase_begins(query)

    if (length(indices) != 0) {
       	print("Matches found for")
        print(query)
    }

    for (i in indices) {

        # Go back to phrases (safer than removes based on indices)
        phrase = allphrases[i]
       	print(phrase)

        if (phrase %in% exceptions == FALSE) {
            C[phrase] <- NULL
        }
    }
}

print("Nr phrases after dropping 'begin' phrases: ")
print(length(colnames(C)))

print("### Handling 'ends' queries ###")
for (query in ends) {
    #print(query)

    # Get all indices
    indices = phrase_ends(query)
 
    if (length(indices) != 0) {
        print("Matches found for")
       	print(query)
    }

    for (i in indices) {
        # Go back to phrases (safer than removes based on indices)
        phrase = allphrases[i]
       	print(phrase)

        if (phrase %in% exceptions == FALSE) {
            C[phrase] <- NULL
        }
    }
}

print("Nr phrases after dropping 'ends' queries: ")
print(length(colnames(C)))

print("### Handling 'includes' queries ###")
for (query in includes) {
    #print(query)

    # Get all indices
    indices = phrase_includes(query)

    if (length(indices) != 0) {
        print("Matches found for")
       	print(query)
    }

    for (i in indices) {
        # Go back to phrases (safer than removes based on indices)
        phrase = allphrases[i]
        print(phrase)
        if (phrase %in% exceptions == FALSE) {
            C[phrase] <- NULL
        }
    }
}
print("Nr phrases after dropping 'includes' phrases: ")
print(length(colnames(C)))
print("First five:")
print(colnames(C)[1:5])

print(length(C))
# Remove 0 rows (i.e. nonspeakers)
C$mu <- rowSums(C)
C <- C[which(C$mu > 0), ]
C$mu <- NULL
print(length(C))

"Went from "
print(beglen)
"phrases to "
print(length(colnames(C)))
"phrases"

saveRDS(C, paste0(output, 'speaker_phrase_counts_bipartisan_adj.rds'))

print("Adjusted C saved to")
print(paste0(output, 'speaker_phrase_counts_bipartisan_adj.rds'))
