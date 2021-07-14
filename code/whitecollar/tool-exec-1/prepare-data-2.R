# NOTE that partyvar is hardcoded!! Couldnt make dplyr work otherwise.

# Counts:
# Include years 1907-2018
# Exclude speeches by chair and MPs from Åland
# Rownames: id's, colnames: phrases
# Save data as RDS

# Metadata:
# Save var's as factors when needed
# Add mu to metadata
# Create randlabel
# Save as RDS

#install needed packages
#install.packages("dplyr", repos="http://cran.r-project.org", lib="/home/jernie/R_libs/")

# Load libraries
library(Matrix)
library(dplyr)
library(tibble)

csc <- 1

# Environment-specific pathroot
ifelse(csc == 1, pathroot <- "/home/jernie/", pathroot <- "/Users/jeremiasnieminen/Dropbox/local_speech/")

########## CHANGE HARDCODED PARTYVAR HERE #########################

partyvar <- expr(whitecollar)

########## CHANGE HARDCODED PARTYVAR HERE #########################

# Paths
input <- paste0(pathroot, 'analysis/input/')
output <- paste0(pathroot, 'analysis/temp/', partyvar, '/')

sprintf("Input path: %s, output path: %s", input, output)

suffix <- '-1907-2018-tf-100-df-10-ytf-10.csv'
set.seed(42)
start.time <- Sys.time()

# Read data
#phrases         <- read.csv(file = paste0(input, "dictionary", suffix), header = TRUE, sep = "|")
C                <- read.csv(file = paste0(input, "bow", suffix), header = TRUE, sep = "|")
speaker_metadata <- read.csv(file = paste0(input, "speaker_metadata_bipartisan.csv"), header=TRUE, sep = "|")

# indices 1-3 are year, speaker_id, id
phrases <- colnames(C[4:length(C)])
print(phrases[1:5])
print("You should see above: 'nuort.aikuist' 'yleis.asumistue' 'huomio.toine' 'asia.valitettav' 'raha.jaeta'")
print(length(phrases))

## Preprocess metadata
speaker_metadata <- speaker_metadata[which(speaker_metadata$year < 2019), ]
sprintf("Metadata len before dropping nan's: %g", nrow(speaker_metadata))

speaker_metadata <- speaker_metadata[which(speaker_metadata[[partyvar]] != ""), ]
sprintf("Metadata len after dropping nan's: %g", nrow(speaker_metadata))

speaker_metadata <- speaker_metadata[which(speaker_metadata$dialect != "Åland"), ]
sprintf("Metadata len after dropping Åland MPs: %g", nrow(speaker_metadata))

# Format variables
speaker_metadata$year        <- as.factor(speaker_metadata$year)
speaker_metadata$dialect     <- as.factor(speaker_metadata$dialect)
speaker_metadata$female      <- as.numeric(speaker_metadata$female)
speaker_metadata$govparty    <- as.numeric(speaker_metadata$govparty)
speaker_metadata$pmparty     <- as.numeric(speaker_metadata$pmparty)
speaker_metadata$id          <- as.character(speaker_metadata$id)
speaker_metadata[[partyvar]] <- as.numeric(speaker_metadata[[partyvar]])

# Randomize partyvar:
# Create a new dataset with non-na party labels 
newdata <- speaker_metadata %>%
  filter(!is.na(!!partyvar))

# Randomize party label
newdata <- newdata %>%
  group_by(year) %>%
  mutate(randlabel = sample(!!partyvar))

# Create check sums to make sure that randomization took place within years
newdata %>% group_by(year) %>% summarize(sumrep = sum(!!partyvar), sumfake = sum(randlabel))

# Keep id and randlabel
newdata <- newdata[c("id", "randlabel")]

# Join new data to metadata
speaker_metadata <- left_join(speaker_metadata, newdata, by = 'id')

# Order, make tibble dataframe
speaker_metadata <- speaker_metadata[order(speaker_metadata$year),]
speaker_metadata <- as_tibble(speaker_metadata)
print(class(speaker_metadata))

# Save metadata as such:
saveRDS(speaker_metadata, file = paste0(output, "speaker_metadata_bipartisan.rds"))
write.table(speaker_metadata, file = paste0(output, "speaker_metadata_bipartisan.csv"), sep = "|", row.names = F)

print(sprintf("Nrows metadata: %g, ncols metadata: %g", nrow(speaker_metadata), ncol(speaker_metadata)))

## Process counts
# C cols: year, speaker_id, id, phrase indices

# Counts 1908-2018, exclude chair speech
C <- C[which(C$year < 2019), ]
sprintf("Rows before excluding chair rows: %g", nrow(C))
C <- C[which(C$speaker_id != '99999'), ]
sprintf("Rows after excluding chair rows: %g", nrow(C))

# Remove year and speaker_id columns
C$year <- NULL
C$speaker_id <- NULL

# Keep rows in speaker metadata
sprintf("Count len before dropping nan's: %g", nrow(C))
C <- subset(C, C$id %in% speaker_metadata$id)
sprintf("Count len after dropping nan's: %g", nrow(C))

# Rownames
rownames(C) <- C[, c('id')]
C$id <- NULL

## Put phrases to count matrix column names
# Colnames
sprintf("Length of phrases: %g", nrow(phrases))
sprintf("Nr columns: %g", ncol(C))

if(length(phrases) != ncol(C)){
   warning("Nr phrases and count columns does not match")
}

#colnames(C) <- phrases$term
#print("Column names:")
#print(colnames(C))

# Order
C <- C[order(row.names(C)), ]

# Nr phrases
nr_phrases = ncol(C)
sprintf("nr phrases: %g", nr_phrases)

# Remove 0 rows (i.e. nonspeakers)
C$mu <- rowSums(C)
C <- C[which(C$mu > 0), ]
C$mu <- NULL

# Remove 0 columns (added March 31, 2020)
'mielipit.pöydällepano' %in% colnames(C)

# Get colsums
e <- colSums(C)
e <- as.data.frame(e)
te <- t(e)
colnames(te) <- colnames(C)

# Keep cols with 0 total in zeros
zeros <- te[,sapply(te,function(x)x == 0), drop = FALSE]

# droppers = phrases with total 0 count
droppers <- colnames(zeros)

"Cols before dropping zero cols: "
dim(C)[2]
for (phrase in droppers) {
    C[phrase] <- NULL
}
"Cols after dropping zero cols: "
dim(C)[2]

stopifnot(('mielipit.pöydällepano' %in% colnames(C)) == FALSE)

# Save C as such:
saveRDS(C, file = paste0(output, "speaker_phrase_counts_bipartisan.rds"))
write.table(C, file = paste0(output, "speaker_phrase_counts_bipartisan.csv"), sep = "|")

print(sprintf("Nrows C: %g, ncols C: %g", nrow(C), ncol(C)))
