# many_models_with_lmer
An example of using a Docker container to create an RStudio environment for reproducibility. This is one way to create an R environment for a specific version of R with specific versions of the packages known to work with our own R code. This allows others to reproduce our environment to verify our code runs as we intend it to.

This example is based on a [blog post by Dave Teng](https://davetang.org/muse/2021/04/24/running-rstudio-server-with-docker/) and has been tested on macOS 12.4 Monterey.

## Usage

- Install [git](https://git-scm.com/downloads) if you don't already have it
- Install [Docker](https://www.docker.com/products/docker-desktop/) using the default settings as prompted
- Build and run your docker container from your Terminal (e.g., bash or Git-Bash on Windows) as follows:

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

- Open your web browser to http://localhost:8888/
- Login as 'rstudio' with password 'password' (or whichever you set it to above)
- In RStudio, run [install_pkgs.R](install_pkgs.R) (takes awhile) which was created by [install_versions.R](install_versions.R) 
- In RStudio, open [many_models_with_lmer.Rmd](many_models_with_lmer.Rmd) and press the "knit" button
- If all goes well, you will be prompted by your web browser to open the [rendered output](many_models_with_lmer.md) as a PDF file
- When you are done using RStudio, stop the container with: `docker stop many_models_with_lmer`
