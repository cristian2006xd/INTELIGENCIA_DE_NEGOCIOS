FROM rocker/rstudio:4.5.1

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       libpq-dev \
       libssl-dev \
       libcurl4-openssl-dev \
       libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN install2.r --error --skipinstalled \
    DBI \
    RPostgres \
    dplyr \
    tidyr \
    ggplot2 \
    lubridate \
    broom \
    scales

RUN mkdir -p /home/rstudio/proyecto \
    && chown -R rstudio:rstudio /home/rstudio/proyecto

USER root
