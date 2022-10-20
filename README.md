# many_models_with_lmer (containerized)
An example of using a Docker container to create an RStudio environment for reproducibility. 

There are a few ways to create an R environment for a specific version of R with specific versions of the packages known to work with our own R code. One of which is using [Docker](https://www.docker.com) containers. Doing so allows others to reproduce our [Linux R/Rstudio environment](https://hub.docker.com/r/rocker/rstudio/tags) to verify our code runs for them as we intend it to. 

## How to install the same package versions elsewhere

However, if all you really want to do is make sure you are using the same package versions on another system, then, in a fresh R session, you can run your R code on the original system and then run this code to save the package versions currently in use to a CSV file:

```
# Save package versions on original system
si <- sessionInfo()
df <- do.call('rbind', 
              lapply(c(si$loadedOnly, si$otherPkgs), 
                     function(x) data.frame(x[c('Package', 'Version')])))
write.csv(df, "package_versions.csv", row.names = FALSE)
```

Then you can copy that CSV file to the alternate system (running the same version of R) and run the following code to install those package versions:

```
# Load devtools, installing as needed, on "clone" system
if (!requireNamespace('devtools', quietly = TRUE)) install.packages('devtools')
library(devtools)

# Install package versions on "clone" system
df <- read.csv("package_versions.csv")
res <- lapply(1:nrow(df), function(x) {
  pkg <- df$Package[x]
  ver <- as.character(df$Version[x])
  if (!try(packageVersion(pkg)) == ver)
    install_version(pkg, version = ver, upgrade = FALSE)
})
```

But if that's not enough, and you want to create a full "clone" development environment with Docker, try the procedure below.

## Example development environment with Docker

You can go a step further by creating a duplicate development environment in a [Docker](https://www.docker.com) container as described below.

This example is based on a [blog post by Dave Teng](https://davetang.org/muse/2021/04/24/running-rstudio-server-with-docker/). It has been tested on macOS 12.4 Monterey and Windows 10 build 19044.

The [Dockerfile](Dockerfile) specifies the R version (R-4.1.3) and the [package install script](install_pkgs.R) which uses (or creates) a [CSV file](package_versions.csv) that specifies which R package versions to install. So, this method (nearly) reproduces the original R environment for running our project R code, to allow someone to reproduce our [results](many_models_with_lmer.md). Our [Rmd file](https://github.com/deohs/coders/blob/main/demos/models/many_models_with_lmer.Rmd) came from the [DEOHS Coders](https://github.com/deohs/coders) repo.

- Install [git](https://git-scm.com/downloads) (free download) if you don't already have it
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (free download) using the default settings as prompted
- Launch Docker Desktop, accept the terms if prompted (and if you agree to them, of course), and skip the tutorial
- Build and run your docker container in Bash from your Terminal (e.g., bash on macOS/Linux, or Git-Bash on Windows) as follows:

```
git clone https://github.com/brianhigh/many_models_with_lmer.git
cd many_models_with_lmer
mkdir -p $HOME/r_packages
docker build -f Dockerfile -t brianhigh/many_models_with_lmer .
docker run --rm -p 8888:8787 -d \
  --name many_models_with_lmer \
  -v $HOME/r_packages/:/packages \
  -e PASSWORD=password -e USERID=$(id -u) -e GROUPID=$(id -g) \
  brianhigh/many_models_with_lmer
```

- If you operating system gives you security prompts to allow Docker, then choose to allow it
- Open your web browser to http://localhost:8888/
- Login as 'rstudio' with password 'password' (or whichever you set it to above)
- In RStudio, open [many_models_with_lmer.Rmd](many_models_with_lmer.Rmd) and press the "Knit" button
- If all goes well, you will be prompted by your web browser to open the [rendered output](many_models_with_lmer.md)
- When you are done using RStudio, stop the container with: `docker stop many_models_with_lmer`

## This takes too long to build!

To speed up the build time, you may prefer to install the R packages from within RStudio *after* building the container. To do so, remove this line from the end of your `Dockerfile` and then rebuild (as described above):

```
RUN Rscript --vanilla /home/rstudio/install_pkgs.R
```

Then run `install_pkgs.R` from within RStudio (running within your container). The R packages should install to `/packages/`, or whatever your `.libPath()` is set to, instead of `/usr/local/lib/R/site-library`. 

If that still takes too long, then you could also reduce the number of packages installed by `install_pkgs.R` to only those explicitly loaded in the project R code (e.g., your Rmd file). That is you could edit `package_versions.csv` to only include those specific packages which your R code (e.g., the Rmd) needs to be attached (loaded) in order to run. This package list will usually match names(sessionInfo()$otherPkgs) after you have attached the packages needed to run your R code.

This would allow the dependencies to be installed with the most recent version supported by your version of R, which may add some flexibility over time, but may also mean that your R environment might deviate too much from the original environment for your liking. So, that's a trade-off to consider.

