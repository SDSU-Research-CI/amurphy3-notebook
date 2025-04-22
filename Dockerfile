ARG BASE_IMAGE=quay.io/jupyter/r-notebook:2025-03-28

FROM $BASE_IMAGE

USER root
WORKDIR /opt

# Install rclone
RUN curl -O https://rclone.org/install.sh \
&& bash install.sh \
&& rm -f install.sh

# Install GlobusConnectPersonal
RUN wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz \
 && tar xzf globusconnectpersonal-latest.tgz \
 && rm globusconnectpersonal-latest.tgz

# Switch back to notebook user
USER $NB_USER
WORKDIR /home/${NB_USER}

COPY oscrtest.yaml oscrtest.yaml

# Create custom environments
RUN mamba env create -f oscrtest.yaml \
 && rm oscrtest.yaml

COPY install_oscr.R install_oscr.R
RUN source activate base \
 && conda activate oscrtest \
 && Rscript install_oscr.R

RUN rm -f install_oscr.R

ENV PATH=/opt/globusconnectpersonal-3.2.6:$PATH
