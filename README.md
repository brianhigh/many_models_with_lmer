# many_models_with_lmer (containerized)
An example of using a Docker "image" to create an RStudio environment (the "container") for reproducibility. 

There are a few ways to create an R environment for a specific version of R with specific versions of the packages known to work with our own R code. One of which is using [Docker](https://www.docker.com). Doing so allows others to reproduce our [Linux R/Rstudio environment](https://hub.docker.com/r/rocker/rstudio/tags) to verify our code runs for them as we intend it to. 

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

You can go a step further by creating a duplicate development environment with [Docker](https://www.docker.com) as described below.

This example is based on a [blog post by Dave Teng](https://davetang.org/muse/2021/04/24/running-rstudio-server-with-docker/). It has been tested on macOS 12.4 Monterey and Windows 10 build 19044.

The [Dockerfile](Dockerfile) specifies the R version (R-4.1.3) and the [package install script](install_pkgs.R) which uses (or creates) a [CSV file](package_versions.csv) that specifies which R package versions to install. So, this method (nearly) reproduces the original R environment for running our project R code, to allow someone to reproduce our [results](many_models_with_lmer.md). Our example [Rmd file](https://github.com/deohs/coders/blob/main/demos/models/many_models_with_lmer.Rmd) came from the [DEOHS Coders](https://github.com/deohs/coders) repo.

- Install [git](https://git-scm.com/downloads) (free download) if you don't already have it
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (free download) using the default settings as prompted
- Launch Docker Desktop, accept the terms if prompted (and if you agree to them, of course), and skip the tutorial
- Build and run your docker image in Bash from your Terminal (e.g., bash on macOS/Linux, or Git-Bash on Windows) as follows:

```
git clone https://github.com/brianhigh/many_models_with_lmer.git
cd many_models_with_lmer
mkdir -p $HOME/r_packages
docker build -t brianhigh/many_models_with_lmer .
```

- To run your image (in a container), use this `docker run` command, substituting `password` for one you choose:

```
docker run --rm -p 8888:8787 -d \
  --name many_models_with_lmer \
  -v $HOME/r_packages/:/packages \
  -e PASSWORD=password -e USERID=$(id -u) -e GROUPID=$(id -g) \
  brianhigh/many_models_with_lmer
```

- Be patient -- this build step can take up to 45 minutes (or more)
- If your operating system gives you security prompts to allow Docker, then choose to allow it
- Open your web browser to http://localhost:8888/
- Login as 'rstudio' with password 'password' (or whichever you set it to above)
- In RStudio, open [many_models_with_lmer.Rmd](many_models_with_lmer.Rmd) and press the "Knit" button or render from R with:

```
rmarkdown::render("many_models_with_lmer.Rmd", output_format = "pdf_document")
```

- If all goes well, a PDF file will be generated containing the [rendered output](many_models_with_lmer.pdf)
- When you are done using RStudio, stop the container with: `docker stop many_models_with_lmer`

## This takes too long to build!

If you know you will not need LaTeX support in your container, or you would prefer to use the [TinyTeX](https://yihui.org/tinytex/) R package, then you can remove this line from your `Dockerfile`:

```
    texlive-latex-extra \
```    

This change will also decrease the storage requirements of the container, as this package is about 100 MB in size. The same goes for some of the other system packages installed in the `Dockerfile`, in that you may not need all of them, or you may need others which are not listed. If you try to install an R package and you get a compiler error saying a `.h` file is missing, or there is a suggestion in the compiler output to install a "deb" package, then the "deb" package(s) listed may need to be installed into your container by listing it in your `Dockerfile` with the other system packages.

There is an [R package](https://cran.r-project.org/web/packages/maketools/vignettes/sysdeps.html) that can help you identify which system packages to install if you have a working Linux system that can already run your R code. Try running the code below to generate a TXT file containing some (but not all) system packages that are required.

```
# Create a TXT file containing a list of Linux system package dependencies
df <- read.csv('package_versions.csv')    # CSV file created by install_pkgs.R
if (!requireNamespace('maketools', quietly = TRUE)) install.packages('maketools')
syspkgs.df <- do.call('rbind', lapply(df$Package, maketools::package_sysdeps))
syspkgs <- sort(unique(syspkgs.df$headers))
writeLines(syspkgs, "system_packages.txt", sep = "\n")
```

To further speed up the build time, you may prefer to install the R packages from within RStudio *after* building the container. This may be helpful as you develop your own image, so that you debug package dependency issues more efficiently. To do so, remove this line from the end of your `Dockerfile` and then rebuild (as described above):

```
RUN Rscript --vanilla /home/rstudio/install_pkgs.R
```

Then run `install_pkgs.R` from within RStudio (running within your container). The R packages should install to `/packages/`, or whatever your `.libPath()` is set to, instead of `/usr/local/lib/R/site-library`. Just be aware that changes made to your running container will be lost when you stop it, as no changes will be saved to the image from which it was created.

If that still takes too long, then you could also reduce the number of packages installed by `install_pkgs.R` to only those explicitly loaded in the project R code (e.g., your Rmd file). That is, you could edit `package_versions.csv` to only include those specific packages which your R code (e.g., the Rmd) needs to be attached (loaded) in order to run. This package list will usually match `names(sessionInfo()$otherPkgs)` after you have attached the packages needed to run your R code.

This would allow the dependencies to be installed with the most recent versions supported by your version of R, which may add some flexibility over time, but may also mean that your R environment might deviate too much from the original environment for your liking.

## How much space is my container using?

You can see a list of your "images" and their sizes with:

```
docker image ls
```

The image size for `brianhigh/many_models_with_lmer` as created above should be 2.87 GB.

If you see some images listed that you know aren't needed, you can [prune](https://docs.docker.com/config/pruning/) them with:

```
docker image prune
```

## How do I update my code or packages to match changes on the original system?

If you make any modifications to the original system that you wish to be replicated in your containerized "clone", then update your `Dockerfile` and related files accordingly, then rebuild your image as described above. If you are using a newer version of R, then refer to that version in the top of the `Dockerfile`. If you have updated your R code or R packages on the original system, then copy those updates to the files used to build your image and rebuild it. If you are sharing those files, as we are here on Github, then update your shared repository once you have confirmed that your Docker container is working properly. 
