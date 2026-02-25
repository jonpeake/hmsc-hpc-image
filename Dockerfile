FROM ghcr.io/nmfs-opensci/py-rocket-base:latest

USER root
COPY apt.txt apt.txt
RUN /pyrocket_scripts/install-apt-packages.sh apt.txt && rm apt.txt
USER ${NB_USER}

COPY environment.yml environment.yml
RUN /pyrocket_scripts/install-conda-packages.sh environment.yml && rm environment.yml

COPY install.R install.R
RUN /pyrocket_scripts/install-r-packages.sh install.R && rm install.R

COPY ./FIM/ FIM/
COPY ./examples/ examples/


