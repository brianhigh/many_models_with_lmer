# Create install commands to install specific package versions matching those
# currently installed.

# Define a list of previously installed packages to be installed elsewhere
pkgs <- c('nycflights13', 'tibble', 'tidyr', 'dplyr', 'lme4', 'broom.mixed', 
          'purrr', 'furrr', 'tictoc', 'kableExtra')

# Get the version numbers
pkgs <- sapply(pkgs, function(x) as.character(packageVersion(x)))

create_install_script <- function(pkgs) {
  c(paste0("if (!requireNamespace('devtools', quietly = TRUE)) install.packages('devtools')"),
    paste0("library(devtools)"), 
    mapply(function(x, y) { 
      paste0("if (!try(packageVersion('", x, "')) == '", y, "') ", "\n  ",
             "install_version('", x, "', version = '", y, "', upgrade = FALSE)")
    }, names(pkgs), pkgs))
}
script <- create_install_script(pkgs)
cat(script, sep = "\n")
