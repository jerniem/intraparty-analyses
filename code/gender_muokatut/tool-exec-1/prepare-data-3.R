# Prepare data for parallel operations

# Split	input count data to k datasets
# Save k versions of metadata to avoid congestion in parallel processing

# args:
# [1]: nr datasets [2]: partyvar [3]: Cpar

csc <- 1

# Environment-specific pathroot
ifelse(csc == 1, pathroot <- "/home/jernie/", pathroot <- "/Users/jeremiasnieminen/Dropbox/local_speech/")

#install.packages("tidyverse", repos="http://cran.r-project.org", lib="/home/jernie/R_libs/")


#library(Matrix)
library(tidyverse)

# Command line arguments
args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 3) {
  stop("Feed nr_datasets, partyvar, cpar as command line arguments")
}

nr_datasets <- as.integer(args[1])
partyvar    <- args[2]
Cpar        <- args[3]

# Paths
input  <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
output <- input
sprintf("Input path: %s, output path: %s", input, output)

# Files
ifelse(Cpar == "Cadj", count_data <- 'speaker_phrase_counts_bipartisan_adj.rds', count_data <- 'speaker_phrase_counts_bipartisan.rds')
metadata   <- 'speaker_metadata_bipartisan.rds'

ifelse(Cpar == "Cadj", suffix <- "_adj", suffix <- "")

start.time <- Sys.time()

# Read data
C                <- readRDS(paste0(input, count_data))
speaker_metadata <- readRDS(paste0(input, metadata))

# Create mu
mu <- rowSums(C)

# Save mu and id to data frame for merging to metadata
muid <- data.frame(mu)
id <- rownames(C)
muid$id <- id

# Merge mu to metadata:
speaker_metadata = left_join(speaker_metadata, muid, by = 'id')

# Nr phrases
nr_phrases = ncol(C)
sprintf("nr phrases: %g", nr_phrases)
chunksize = nr_phrases/nr_datasets

# split C into smaller datasets
# Choose columns for each data

splits = split(colnames(C), rep(1:nr_datasets, ceiling(chunksize)))

d = 1

for(sp in splits){

    # Subset count data
    cur <- C[, c(sp)]
    nphrase <- ncol(cur)

    print(sprintf("data-%g: Rows in data: %g, cols in data: %g", d, nrow(cur), ncol(cur)))
    #print(cur)

    filename = paste0('data_', d, suffix, '.rds')
    saveRDS(cur, file = paste0(output, filename))

    print(sprintf("Counts for %g phrases saved to %s%s", nphrase, output, filename))

    d = d + 1
}

# Save nr_datasets copies of metadata:
print(speaker_metadata[which(speaker_metadata$speaker_id ==368), ])
saveRDS(speaker_metadata, file = paste0(output, 'speaker_metadata_bipartisan_mu.rds'))
write.table(speaker_metadata, file = paste0(output, "speaker_metadata_bipartisan_mu.csv"), sep = "|", row.names = F)

for(d in 1:nr_datasets){
    saveRDS(speaker_metadata, file = paste0(output, 'speaker_metadata_data_', d, suffix, '.rds'))
}

end.time <- Sys.time()
process.time <- end.time - start.time
sprintf("Process took %g minutes", process.time)

