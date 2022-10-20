# Save package names and versions to a CSV or, if this file exists, install
# the package versions listed in it. This is for duplicating one R 
# environment to another with the same R package versions.

# Set repository URL
r <- getOption("repos")
r["CRAN"] <- "https://cloud.r-project.org"
options(repos = r)

# Set data folder path
data_dir <- '/home/rstudio'
if (!dir.exists(data_dir)) data_dir <- '.'

# Set data file path
csv_file <- 'package_versions.csv'
csv_path <- file.path(data_dir, csv_file)

if (!file.exists(csv_path)) {
  # Save package versions on original system
  si <- sessionInfo()
  df <- do.call('rbind', 
                lapply(c(si$loadedOnly, si$otherPkgs), 
                       function(x) data.frame(x[c('Package', 'Version')])))
  write.csv(df, csv_path, row.names = FALSE)
  print(paste("Copy", csv_path, "and this script to distination and run it."))
} else {
  # Load devtools, installing as needed
  if (!requireNamespace('devtools', quietly = TRUE)) 
    install.packages('devtools')
  library(devtools)
  
  # Install package versions listed in CSV file
  df <- read.csv(csv_path)
  res <- lapply(1:nrow(df), function(x) {
    pkg <- df$Package[x]
    ver <- as.character(df$Version[x])
    if (!try(packageVersion(pkg)) == ver)
      install_version(pkg, version = ver, upgrade = FALSE)
  })
}

