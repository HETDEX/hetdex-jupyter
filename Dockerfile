# Copyright (c) HETDEX Data Team

#ARG BASE_CONTAINER=jupyter/scipy-notebook:2024-11-04
ARG BASE_CONTAINER=quay.io/jupyter/scipy-notebook:2024-11-04
FROM $BASE_CONTAINER

LABEL maintainer="Erin Mentuch Cooper <erin@astro.as.utexas.edu>"

USER root

RUN apt-get update && apt-get install -y poppler-utils

USER jovyan

RUN echo 'PS1="\w $ "' >> ~/.bashrc

#force earlier versions than what hetdex-api will install
RUN pip install numpy==1.26.4

# pip install packages
RUN pip install speclite && \
    pip install agavepy && \
    pip install dustmaps && \
    pip install nway && \
    pip install alive-progress && \
    pip install holoviews && \
    pip install corner && \
    pip install tqdm && \
    pip install ligo.skymap && \
    pip install plotly==5.20.0 && \
    pip install -U kaleido==0.2.1 && \
    pip install filelock && \
    pip install --extra-index-url https://gate.mpe.mpg.de/pypi/simple/ pyhetdex

# Pip install hetdex-api, elixer in software directory

RUN chown -R jovyan /home/jovyan/ && \
    chmod 777 /home/jovyan
    
RUN mkdir /home/jovyan/software/ 
    
WORKDIR /home/jovyan/software

RUN pip install tables

RUN chown -R jovyan /home/jovyan/software && \
    chmod 777 /home/jovyan/software

RUN git clone https://github.com/HETDEX/hetdex_api.git  && \
    ( cd hetdex_api && pip install -e .) && \
    fix-permissions "/home/jovyan"

RUN git clone https://github.com/HETDEX/elixer.git  && \
    cd elixer && git checkout dev-dustin && pip install -e . && \
    fix-permissions "/home/jovyan"

RUN pip install tapipy --ignore-installed certifi

RUN pip install pyimfit

RUN pip install --upgrade jupyterlab jupyterlab_server jupyter_server traitlets nbformat

RUN chown -R jovyan /home/jovyan/software && \
    chmod 777 /home/jovyan/software

RUN export HOME='/home/jovyan'

RUN echo "export PATH=$HOME/.local/bin:${PATH}" >> ~/.bashrc

WORKDIR $HOME

RUN cp -r software/hetdex_api/notebooks/ /home/jovyan/hetdex-notebooks

# Copy notebooks for catalog access

RUN mkdir /home/jovyan/your_temporary_workspace && \
    cp software/hetdex_api/notebooks/public/HETDEX_*.ipynb /home/jovyan/your_temporary_workspace/
    

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/jovyan/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/jovyan"

WORKDIR /home/jovyan

RUN chown -R jovyan /home/jovyan/ && \
    chmod 777 /home/jovyan && \ 
    chmod -R 777 /home/jovyan/software/ && \
    chmod -R 777 /home/jovyan/hetdex-notebooks/ && \
    chmod -R 777 /home/jovyan/your_temporary_workspace/ && \
    chmod -R 777 /home/jovyan/.config/ && \
    chmod -R 777 /home/jovyan/.cache/matplotlib/ && \
    chmod -R 777 /home/jovyan/.cache/

RUN ln -s /home/jovyan/team_classify/shared shared

USER jovyan