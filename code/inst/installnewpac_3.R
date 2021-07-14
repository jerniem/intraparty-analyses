#install.packages("devtools")
library(devtools)
#install_github("TaddyLab/distrom")

devtools::install_github("TaddyLab/distrom", args = c('--library="/home/jernie/new_env/lib/R/library/"'))

#with_libpaths(new = "/home/jernie/new_env/lib/R/library/", install_github("TaddyLab/distrom"))

#library(withr)
#withr::with_libpaths(new = "/home/jernie/new_env/lib/R/library/", install_github("TaddyLab/distrom"))

