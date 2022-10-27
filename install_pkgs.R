# Install packages for specific versions to duplicate an R environment on 
# another system.

# From the Github repo: https://github.com/brianhigh/many_models_with_lmer

# The hard way...

# First install the same version of R as on the original system, e.g., R-4.1.3:
# - macOS: https://cran.microsoft.com/snapshot/2022-03-21/bin/macosx/
# - Windows: https://cran.microsoft.com/snapshot/2022-04-11/bin/windows/base/

# Second, install the same version of RStudio as on the original system,
# e.g., RStudio 2021.09.1+372 "Ghost Orchid":
# https://dailies.rstudio.com/version/2021.09.1+372.pro1/

# Third, for macOS, install Xcode from the Apple AppStore and also install 
# gfortran from: https://mac.r-project.org/tools/
# And, again for macOS, also install Homebrew from: https://brew.sh 
# ... and with Homebrew install cmake, libpng and freetype (and maybe more)
# Then close and re-open RStudio before proceeding. 

# Similarly, for Windows, install RTools for the version of R you are using:
# https://cran.r-project.org/bin/windows/Rtools/
# For Linux, you will need a number of development packages and system
# libraries too numerous to mention here, and the names of which will
# vary depending on which distribution and version of Linux you are using.

# The easy way...

# If you would rather not bother with all of the above installations, an 
# alternative is to just install Docker to run RStudio Server as described here:
# https://davetang.org/muse/2021/04/24/running-rstudio-server-with-docker/
# To match the R version on the original system, you would start your Dockerfile 
# with, e.g.:
# FROM rocker/rstudio:4.1.3
# ... Then you can install your R packages using the script generated below.

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
