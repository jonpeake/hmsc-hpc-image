FROM nvcr.io/nvidia/tensorflow:25.02-tf2-py3


RUN apt update -qq
RUN apt install --yes --no-install-recommends software-properties-common dirmngr
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the repo from CRAN -- lsb_release adjusts to 'noble' or 'jammy' or ... as needed
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    apt update -qq && apt install --yes --no-install-recommends wget ca-certificates gnupg  && \
    apt install --yes r-base r-base-dev && \
    wget -q -O- https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc | tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc && \
    echo "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu jammy main" > /etc/apt/sources.list.d/cranapt.list
    
RUN apt update -qq && \
    echo "Package: *" > /etc/apt/preferences.d/99cranapt && \
    echo "Pin: release o=CRAN-Apt Project" >> /etc/apt/preferences.d/99cranapt && \
    echo "Pin: release l=CRAN-Apt Packages" >> /etc/apt/preferences.d/99cranapt && \ 
    echo "Pin-Priority: 700"  >> /etc/apt/preferences.d/99cranapt
## Then install bspm (as root) and enable it, and enable a speed optimization
RUN Rscript -e 'install.packages("bspm")' && \
    RHOME=$(R RHOME) && \
    echo "suppressMessages(bspm::enable())" >> ${RHOME}/etc/Rprofile.site && \
    echo "options(bspm.version.check=FALSE)" >> ${RHOME}/etc/Rprofile.site


COPY apt.txt apt.txt
RUN sudo apt-get update && apt-get install -y --no-install-recommends \
    $(cat apt.txt) && \
    rm -rf /var/lib/apt/lists/*

COPY install.R install.R
RUN Rscript install.R

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir git+https://github.com/hmsc-r/hmsc-hpc.git

COPY ./FIM/ FIM/
COPY ./examples/ examples/


