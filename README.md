# many_models_with_lmer (containerized)
An example of using a Docker container to create an RStudio environment for reproducibility. 

This is one way to create an R environment for a specific version of R with specific versions of the packages known to work with our own R code. This allows others to reproduce our [Linux R/Rstudio environment](https://hub.docker.com/r/rocker/rstudio/tags) to verify our code runs for them as we intend it to. 

The [Dockerfile](Dockerfile) specifies the R version (R-4.1.3) and the [package install script](install_pkgs.R) specifies which R package versions to install. This script was created with a [helper script](install_versions.R) (and [another one](install_package_versions.R)) run on the original system that our [project R code](many_models_with_lmer.Rmd) was developed on. So, this method (very nearly) reproduces the original R environment for running our project R code, to allow someone to reproduce our [results](many_models_with_lmer.md). Our [Rmd file](https://github.com/deohs/coders/blob/main/demos/models/many_models_with_lmer.Rmd) came from the [DEOHS Coders](https://github.com/deohs/coders) repo.

This example is based on a [blog post by Dave Teng](https://davetang.org/muse/2021/04/24/running-rstudio-server-with-docker/). It has been tested on macOS 12.4 Monterey and Windows 10 build 19044.

## Usage

- Install [git](https://git-scm.com/downloads) (free download) if you don't already have it
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (free download) using the default settings as prompted
- Launch Docker Desktop, accept the terms if prompted (and if you agree to them, of course), and skip the tutorial
- Build and run your docker container in Bash from your Terminal (e.g., bash on macOS/Linux, or Git-Bash on Windows) as follows:

```
git clone https://github.com/brianhigh/many_models_with_lmer.git
cd many_models_with_lmer
mkdir -p $HOME/r_packages
docker build -f Dockerfile .
docker build -t brianhigh/many_models_with_lmer .
docker run --rm -p 8888:8787 -d \
  --name many_models_with_lmer \
  -v $HOME/r_packages/:/packages \
  -e PASSWORD=password -e USERID=$(id -u) -e GROUPID=$(id -g) \
  brianhigh/many_models_with_lmer
```

- If you operating system gives you security prompts to allow Docker, then choose to allow it
- Open your web browser to http://localhost:8888/
- Login as 'rstudio' with password 'password' (or whichever you set it to above)
- In RStudio, open [install_pkgs.R](install_pkgs.R) and press the "Source" button (takes awhile)
- In RStudio, open [many_models_with_lmer.Rmd](many_models_with_lmer.Rmd) and press the "Knit" button
- If all goes well, you will be prompted by your web browser to open the [rendered output](many_models_with_lmer.md) as a PDF file
- When you are done using RStudio, stop the container with: `docker stop many_models_with_lmer`

If you would prefer to have the R packages installed into the container when building it, then add this line to the end of your `Dockerfile`:

```
RUN Rscript --vanilla /home/rstudio/install_pkgs.R
```

And then rebuild as described above. The R packages will install to `/usr/local/lib/R/site-library`. 

If that makes the initial build take too long, you could also reduce the number of packages installed in `install_pkgs.R` to only those explicitly loaded in the project R code (e.g., your Rmd file). 

For example, `install_pkgs.R` could be:

---
if (!requireNamespace('devtools', quietly = TRUE)) install.packages('devtools')
library(devtools)

if (!try(packageVersion('knitr')) == '1.40') 
  install_version('knitr', version = '1.40', upgrade = FALSE)
if (!try(packageVersion('kableExtra')) == '1.3.4') 
  install_version('kableExtra', version = '1.3.4', upgrade = FALSE)
if (!try(packageVersion('tictoc')) == '1.0.1') 
  install_version('tictoc', version = '1.0.1', upgrade = FALSE)
if (!try(packageVersion('furrr')) == '0.2.3') 
  install_version('furrr', version = '0.2.3', upgrade = FALSE)
if (!try(packageVersion('purrr')) == '0.3.5') 
  install_version('purrr', version = '0.3.5', upgrade = FALSE)
if (!try(packageVersion('broom.mixed')) == '0.2.9.4') 
  install_version('broom.mixed', version = '0.2.9.4', upgrade = FALSE)
if (!try(packageVersion('lme4')) == '1.1-30') 
  install_version('lme4', version = '1.1-30', upgrade = FALSE)
if (!try(packageVersion('dplyr')) == '1.0.8') 
  install_version('dplyr', version = '1.0.8', upgrade = FALSE)
if (!try(packageVersion('tidyr')) == '1.2.0') 
  install_version('tidyr', version = '1.2.0', upgrade = FALSE)
if (!try(packageVersion('tibble')) == '3.1.8') 
  install_version('tibble', version = '3.1.8', upgrade = FALSE)
if (!try(packageVersion('nycflights13')) == '1.0.2') 
  install_version('nycflights13', version = '1.0.2', upgrade = FALSE)
---

This would allow the dependencies to be installed with whatever versions R chooses, which may add some flexibility over time, but may also mean that your R environment might deviate too much from the original environment for your liking. So, that's a trade-off to consider.

