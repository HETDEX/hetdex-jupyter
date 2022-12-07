# Copyright (c) HETDEX Data Team

#ARG BASE_CONTAINER=jupyter/scipy-notebook:python-3.9.4
ARG BASE_CONTAINER=jupyter/scipy-notebook:2022-08-15

FROM $BASE_CONTAINER

LABEL maintainer="Erin Mentuch Cooper <erin@astro.as.utexas.edu>"

USER jovyan

RUN echo 'PS1="\w $ "' >> ~/.bashrc

# pip install packages
RUN pip install speclite==0.16 && \
    pip install agavepy && \
    pip install dustmaps && \
#    pip install torch && \
    pip install nway && \
#    pip install netcal && \
    pip install alive-progress && \
#    pip install holoviews && \
    pip install tqdm && \
    pip install ligo.skymap && \
    pip install plotly && \
    pip install pyimfit && \
    pip install --extra-index-url https://gate.mpe.mpg.de/pypi/simple/ pyhetdex
    
# Pip install hetdex-api, elixer in software directory

RUN chown -R jovyan /home/jovyan/ && \
    chmod 777 /home/jovyan
    
RUN mkdir /home/jovyan/software/ 
    
WORKDIR /home/jovyan/software

RUN chown -R jovyan /home/jovyan/software && \
    chmod 777 /home/jovyan/software

#RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
#    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
#    jupyter lab build -y --dev-build=False --minimize=False && \
#    jupyter lab clean -y 

RUN git clone https://github.com/HETDEX/hetdex_api.git  && \
    ( cd hetdex_api && pip install -e .) && \
    fix-permissions "/home/jovyan" 

RUN git clone https://github.com/HETDEX/elixer.git  && \
    cd elixer && git checkout dev-dustin && pip install -e . && \
    fix-permissions "/home/jovyan"

RUN pip install tapipy --ignore-installed certifi

RUN chown -R jovyan /home/jovyan/software && \
    chmod 777 /home/jovyan/software

RUN export HOME='/home/jovyan'

RUN echo "export PATH=$HOME/.local/bin:${PATH}" >> ~/.bashrc

WORKDIR $HOME

RUN cp -r software/hetdex_api/notebooks/ /home/jovyan/hetdex-notebooks

# Copy notebooks for catalog access

RUN mkdir /home/jovyan/your_temporary_workspace && \
    cp software/hetdex_api/notebooks/HETDEX_*.ipynb /home/jovyan/your_temporary_workspace/
    

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/jovyan/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/jovyan"

WORKDIR /home/jovyan

RUN chown -R jovyan /home/jovyan/ && \
    chmod 777 /home/jovyan && \ 
    chmod -R 777 /home/jovyan/software/ && \
    chmod -R 777 /home/jovyan/hetdex-notebooks/ && \
    chmod -R 777 /home/jovyan/.config/ && \
    chmod -R 777 /home/jovyan/.cache/matplotlib/ && \
    chmod -R 777 /home/jovyan/.cache/

RUN ln -s /home/jovyan/team_classify/shared shared

USER jovyan