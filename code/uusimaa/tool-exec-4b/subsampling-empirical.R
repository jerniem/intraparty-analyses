# Rscript subsampling-empirical.R 1 "left" 0 "Cadj"
library(distrom)
library(dplyr)

args           <- commandArgs(trailingOnly=TRUE)
subnr          <- as.integer(args[1])
partyvar       <- args[2]
fake_indicator <- as.integer(args[3])
Cpar           <- args[4]

set.seed(subnr)
csc <- 1

partyvar <- expr(gender)

# Environment-specific pathroot
ifelse(csc == 1, pathroot <-  "/home/jernie/", pathroot <- "/Users/jeremiasnieminen/Dropbox/local_speech/")

# Folders
input  <- paste0(pathroot, 'analysis/temp/', partyvar, '/')
output <- paste0(pathroot, 'analysis/temp/', partyvar, '/empirical/')

ifelse(fake_indicator == 1, suffix <- "_randlabels", suffix <- "")
ifelse(Cpar == "Cadj", suffix <- paste0(suffix, "_Cadj"), suffix <- paste0(suffix, ""))

outfile <- paste0('partisanship-', partyvar, suffix, '-', as.character(subnr), '-yearsonly.csv')
ifelse(fake_indicator == 1, partyvar <- expr(randlabel), partyvar <- partyvar)

nr_cores <- 2

sprintf("Using %s as party variable", str(partyvar))
sprintf("Outfile: %s", outfile)

# Point to right objects objects
ifelse(Cpar == "Cadj", cdata <- "speaker_phrase_counts_bipartisan_adj.rds", cdata <- "speaker_phrase_counts_bipartisan.rds")
ifelse(Cpar == "Cadj", metadata <- "speaker_metadata_data_1_adj.rds", metadata <- "speaker_metadata_data_1.rds")

# Load objects
full_data        <- readRDS(paste0(input, metadata))
C                <- readRDS(paste0(input, cdata))

# Drop if missing party label:
full_data <- full_data[which(full_data[[partyvar]] != ""), ]

C$id <- rownames(C)
C <- subset(C, C$id %in% full_data$id)
C$id <- NULL
# This subsetting is just to double check since prepare-data2.R already does this 

# Keep rows where rowsum(C) > 0
rownames(full_data) <- full_data$id
full_data <- full_data[rownames(C), ]

tocheck <- full_data %>%
  group_by(year, !!partyvar) %>%
  count(year)

print(tocheck, n = 200)

# Discard 1918 and 1939: less than 30 MPs in the left parties.
full_data <- full_data[which(full_data$year != 1918), ]
full_data <- full_data[which(full_data$year != 1939), ]

all_speakers <- full_data %>%
  group_by(year) %>%
  count(year)

all_speakers <- all_speakers %>%
  rename(session = year,
  all_speakers = n)
# all_speakers data ready

# Sample 20 percent of data without replacement
# Handle two tricky years separately.
# 1918: only one left MP
# 1939: Winter War, very little speech and thus speakers (esp. left) 
# Sample 1 speaker from left party separately for the two years

#tricky1 <- full_data[which(full_data$year == 1918 & full_data[[partyvar]] == 1),]
#tricky2 <- full_data[which(full_data$year == 1939 & full_data[[partyvar]] == 1),]

#t1 <- sample_n(tricky1, 1)
#t2 <- sample_n(tricky2, 1)
#t  <- rbind(t1, t2)

# Sample from adjusted full_data to avoid duplicates
#full_data_adj <- subset(full_data, !(full_data$id %in% t$id))
#newdata <- sample_frac(full_data_adj, 0.20, replace = FALSE)
newdata <- sample_frac(full_data, 0.20, replace = FALSE)

# Combine special cases and rest
#newdata <- rbind(newdata, t)

# Nr of sampled speakers to subsize data:
subsize <- newdata %>%
  group_by(year) %>%
  count(year)

# Check stats by party-year:
tocheck <- newdata %>%
  group_by(year, !!partyvar) %>%
  count(year)

print(tocheck, n = 200)

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

C    <- as.matrix(C)
C    <- as.data.frame(C)
C$id <- rownames(C)

print(dim(C))
C <- subset(C, C$id %in% speaker_metadata$id)
print(dim(C))

print(dim(speaker_metadata))
speaker_metadata <- subset(speaker_metadata, speaker_metadata$id %in% C$id)
print(dim(speaker_metadata))

C$id <- NULL
nr_phrases <- dim(C)[2]
C$totals <- rowSums(C)

C$session <- speaker_metadata$year
C$republican <- speaker_metadata[[partyvar]]

grouped <- C %>% group_by(session,republican) %>% summarize_all(sum)
#n <- length(grouped)
#print(grouped$totals)

q <- sapply(grouped, function(x) x/grouped$totals)
q <- as.data.frame(q)

q$totals <- NULL
q$session <- grouped$session
q$republican <- grouped$republican

q_dem <- q[which(q$republican ==0),] 
q_rep <- q[which(q$republican ==1),] 

rownames(q_dem) <- q_dem$session
q_dem$session <- NULL
q_dem$republican <- NULL

rownames(q_rep) <- q_rep$session
q_rep$session <- NULL
q_rep$republican <- NULL

stopifnot(dim(q_dem)[2] == nr_phrases)
stopifnot(dim(q_rep)[2] == nr_phrases)

rho       <- q_rep/(q_dem + q_rep)
# fill na's (result from division with zero) with 0
rho[is.na(rho)] <- 0

stopifnot(dim(rho)[2] == nr_phrases)

pi <- rowSums(0.5 * q_rep * rho + 0.5 * q_dem * (1-rho))
pi <- data.frame(session = as.integer(names(pi)), pi = pi)

# Make sure all keys are of same type:
pi$session             <- as.factor(pi$session)
subsize$session        <- as.factor(subsize$session)
all_speakers$session   <- as.factor(all_speakers$session)

pi = left_join(pi, subsize, by = 'session')
pi = left_join(pi, all_speakers, by = 'session')

write.csv(pi, file = paste0(output, outfile), row.names = F, quote = F)

sprintf("Process %g completed", subnr)
Sys.time()



#write.csv(pi, file = paste0(output, 'empirical-partisanship-', partyvar, suffix, '.csv'), row.names = F, quote = F)
