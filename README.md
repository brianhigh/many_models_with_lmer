# many_models_with_lmer
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

If that makes the initial build take too long, you could also reduce the number of packages installed in `install_pkgs.R` to only those explicitly loaded in the project R code (e.g., your Rmd file). This would allow the dependencies to be installed with whatever version R chooses, which may add some flexibility over time, but may also mean that your R environment deviates too much from the original environment for your liking. So, that's a trade-off.

