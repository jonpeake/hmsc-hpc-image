FROM vastai/tensorflow:2.19.0-cuda-12.4.1

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


