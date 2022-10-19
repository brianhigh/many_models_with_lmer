# many_models_with_lmer
An example of using a Docker container to create an RStudio environment for reproducibility. This is one way to create an R environment for a specific version of R with specific versions of the packages known to work with our own R code. This allows others to reproduce our environment to verify our code runs as we intend it to.

This example has been tested on macOS 12.4 Monterey.

## Usage

- Install [Docker](https://www.docker.com/products/docker-desktop/)
- Build and run your docker container as follows:

```
git clone git@github.com:brianhigh/many_models_with_lmer.git
cd many_models_with_lmer
mkdir -p $HOME/r_packages
docker build -f Dockerfile .
docker build -t brianhigh/many_models_with_lmer
docker run --rm -p 8888:8787 -d --name many_models 
  -v $HOME/r_packages/:/packages 
  -e PASSWORD=password -e USERID=$(id -u) -e GROUPID=$(id -g)
```

- Open your web browser to http://localhost:8888/
- Login as 'rstudio' with password 'password' (or whichever you set it to above)
- In RStudio, run install_pkgs.R (takes while) then open many_models_with_lmer.Rmd and "knit"
- If all goes well, you will be prompted by your web browser to open the rendered output