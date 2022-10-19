# Install packages for specific versions to duplicate an R environment on 
# another system -- from RStudio Server on Ubuntu to RStudio Desktop on macOS.

# First install the same version of R as on Plasmid (R-4.1.3) for macOS from:
# https://mran.microsoft.com/snapshot/2022-03-21/bin/macosx/

# Second, install the same version of RStudio as on Plasmid ...
# RStudio 2021.09.1+372 "Ghost Orchid" for macOS from:
# https://dailies.rstudio.com/version/2021.09.1+372.pro1/

# Third, install Xcode from the Apple AppStore and also install gfortran
# from: https://mac.r-project.org/tools/gfortran-8.2-Mojave.dmg
# And also install Homebrew from: https://brew.sh 
# ... and with Homebrew install cmake, libpng and freetype (and maybe more)
# Then close and re-open RStudio before proceeding.

# If you would rather not bother with all of the above installations, an 
# alternative is to just install Docker to run RStudio Server as described here:
# https://davetang.org/muse/2021/04/24/running-rstudio-server-with-docker/
# To match the R version on Plasmid, you would start your Dockerfile with:
# FROM rocker/rstudio:4.1.3
# Then you can install your R packages using the script generated below.

# Define file path of the installation script for specific package versions
inst_script <- "install_pkgs.R"

# The next section should be run on the original system to capture 
# package versions used after our own R scripts were run:
create_install_script <- function(si) {
  pkgs <- sapply(c(si$loadedOnly, si$otherPkgs), function(x) x$Version)
  c(paste0("if (!requireNamespace('devtools', quietly = TRUE)) install.packages('devtools')"),
    paste0("library(devtools)"), 
    mapply(function(x, y) { 
      paste0("if (!try(packageVersion('", x, "')) == '", y, "') ", "\n  ",
             "install_version('", x, "', version = '", y, "', upgrade = FALSE)")
    }, names(pkgs), pkgs))
}
if (!file.exists(inst_script)) 
  writeLines(create_install_script(sessionInfo()), inst_script)

# And that script should be copied to the destination system and run (see below)

# Install packages
if (file.exists(inst_script)) source(inst_script, echo = TRUE)



