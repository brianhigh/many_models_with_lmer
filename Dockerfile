FROM rocker/rstudio:4.1.3
 
MAINTAINER Brian High https://github.com/brianhigh/
 
RUN apt-get clean all && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    libhdf5-dev \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libxt-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libglpk40 \
    libgit2-28 \
    libfontconfig1-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libfreetype-dev \
    texlive-latex-extra \
    cmake \
  && apt-get clean all && \
  apt-get purge && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
COPY install_pkgs.R /home/rstudio/
COPY many_models_with_lmer.Rmd /home/rstudio/
COPY .Rprofile /home/rstudio/
COPY package_versions.csv /home/rstudio/
RUN Rscript --vanilla /home/rstudio/install_pkgs.R

