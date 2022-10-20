# Set repository URL
r <- getOption("repos")
r["CRAN"] <- "https://cloud.r-project.org"
options(repos = r)

# Install LaTeX environment (for rendering PDFs from RMarkdown, etc.)
pdflatex_ver <- try(system("pdflatex -v", intern = T, wait = T), silent = T)
pdflatex_ver <- grep("^pdfTeX", pdflatex_ver, value = T)
if (!(exists("pdflatex_ver") & length(pdflatex_ver) > 0)) {
  if (!requireNamespace("tinytex", quietly = TRUE)) install.packages("tinytex")
  if (!dir.exists(tinytex::tinytex_root(error = F))) tinytex::install_tinytex()
}

# Load devtools, installing as needed
if (!requireNamespace('devtools', quietly = TRUE)) install.packages('devtools')
library(devtools)

# Install packages
df <- read.csv("/home/rstudio/package_versions.csv")
res <- lapply(1:nrow(df), function(x) {
  pkg <- df$Package[x]
  ver <- as.character(df$Version[x])
  if (!try(packageVersion(pkg)) == ver)
    install_version(pkg, version = ver, upgrade = FALSE)
})

