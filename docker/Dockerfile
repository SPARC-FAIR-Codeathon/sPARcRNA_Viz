# Docker base image, change if needed
FROM ubuntu:24.04 AS base

# ------------------------------------------------------------------------------------
# Install system packages and R
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
    curl jq zip adduser \
    libcurl4-openssl-dev libssl-dev libxml2-dev libhdf5-dev python3 python3-pip \
    libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev \  # required for R packages
  && echo "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" >> /etc/apt/sources.list \
  && curl -sL "https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc" | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
  && apt-get update \
    && apt-get -y install --no-install-recommends \
        r-base \
        r-base-dev \
  && rm -rf /var/lib/apt/lists/*
# ------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------
# oSPARC compatibility, do not modify
# simcore-user uid=8004(${SC_USER_NAME}) gid=8004(${SC_USER_NAME}) groups=8004(${SC_USER_NAME})
ENV SC_USER_ID 8004
ENV SC_USER_NAME scu
RUN adduser --uid ${SC_USER_ID} --disabled-password --gecos "" --shell /bin/sh --home /home/${SC_USER_NAME} ${SC_USER_NAME}
# ------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------
# Install Bioconductor
RUN R -e "install.packages('BiocManager', repos='http://cran.rstudio.com/')"
# Install required R packages available on CRAN
RUN R -e "install.packages(c('Seurat', 'jsonlite', 'optparse', 'ggplot2', 'devtools', 'dplyr', 'msigdbr'), repos='http://cran.rstudio.com/')"
# Install required R packages available on Bioconductor
RUN R -e "BiocManager::install('fgsea')"
# Install presto for speed-ups to Seurat
RUN R -e "library(devtools); devtools::install_github('immunogenomics/presto')"

# Remove the Python warning about system installs since we're in a docker image
RUN rm /usr/lib/python*/EXTERNALLY-MANAGED
# Install required Python packages
RUN pip3 install pandas
# ------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------
# Copy and set up R script
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} src/pipeline/dex.R /home/${SC_USER_NAME}/
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} src/astro /home/${SC_USER_NAME}/astro
RUN chmod +x /home/${SC_USER_NAME}/dex.R
# ------------------------------------------------------------------------------------

# --------------------------------- Final setup  --------------------------------------
# Do not modify

ENV INPUT_FOLDER="/input" \
    OUTPUT_FOLDER="/output"

WORKDIR /home/${SC_USER_NAME}

# copy docker bootup scripts
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} docker/*.sh docker/

# copy simcore service cli
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} service.cli/ service.cli/
# necessary to be able to call run directly without sh in front
ENV PATH="/home/${SC_USER_NAME}/service.cli:${PATH}"

ENTRYPOINT [ "/bin/sh", "docker/entrypoint.sh", "/bin/sh", "-c" ]
CMD ["run"]
# -------------------------------------------------------------------------------------

