# Copyright (c) HETDEX Data Team

ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Erin Mentuch Cooper <erin@astro.as.utexas.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng+cm-super for latex labels
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg dvipng cm-super && \
    rm -rf /var/lib/apt/lists/*

#USER $NB_UID
USER jovyan
RUN echo 'PS1="\w $ "' >> ~/.bashrc
# Install Python 3 packages
RUN conda install --quiet --yes \
    'astropy=4.0.*' \
    'astropy-healpix=0.5*' \
    'astrowidgets=0.1.*' \
    'astroquery==0.4.*' \ 
    'beautifulsoup4=4.9.*' \
    'conda-forge::blas=*=openblas' \
    'bokeh=2.2.*' \
    'bottleneck=1.3.*' \
    'cloudpickle=1.6.*' \
    'cython=0.29.*' \
    'dask=2.25.*' \
    'dill=0.3.*' \
    'healpy=1.13.*' \
    'h5py=2.10.*' \
    'ipywidgets=7.5.*' \
    'ipympl=0.5.*'\
    'matplotlib-base=3.3.*' \
    'numba=0.51.*' \
    'numexpr=2.7.*' \
    'pandas=1.1.*' \
    'patsy=0.5.*' \
    'plotly=4.11.*' \
    'photutils=0.7.*' \
    'protobuf=3.12.*' \
    'pytables=3.6.*' \
    'regions' \
    'scikit-image=0.17.*' \
    'scikit-learn=0.23.*' \
    'scipy=1.5.*' \
    'seaborn=0.11.*' \
    'sep=1.0.*' \
    'specutils=1.*' \
    'widgetsnbextension=3.5.*'\
    && \
    # install kaleido in order to export plotly figures
    conda clean --all -f -y && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    # Check this URL for most recent compatibilities
    # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^2.0.0 --no-build && \
    jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/jovyan/.cache/yarn" && \
    rm -rf "/home/jovyan/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \ 
    fix-permissions "/home/jovyan"

# pip install packages that don't have conda installs
RUN pip install speclite==0.8 && \
    pip install --extra-index-url https://gate.mpe.mpg.de/pypi/simple/ pyhetdex && \
    pip install -U kaleido

# Pip install hetdex-api, elixer in software directory

RUN chown -R jovyan /home/jovyan/ && \
    chmod 777 /home/jovyan
    
RUN mkdir /home/jovyan/software/ 
    
WORKDIR /home/jovyan/software

RUN chown -R jovyan /home/jovyan/software && \
    chmod 777 /home/jovyan/software
    
RUN git clone https://github.com/HETDEX/hetdex_api.git  && \
    ( cd hetdex_api && pip install -e .) && \
    fix-permissions "/home/jovyan" 

RUN git clone https://github.com/HETDEX/elixer.git  && \
    cd elixer && git checkout dev-dustin && pip install -e . && \
    fix-permissions "/home/jovyan"

RUN chown -R jovyan /home/jovyan/software && \
    chmod 777 /home/jovyan/software

RUN export HOME='/home/jovyan'
WORKDIR $HOME

RUN cp -r software/hetdex_api/notebooks/ /home/jovyan/hetdex-notebooks && \
    mkdir your_classify_dir && \
    cp software/hetdex_api/notebooks/classify-widget.ipynb your_classify_dir/ && \
    cp software/hetdex_api/notebooks/training-examples.ipynb your_classify_dir/ 

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/jovyan/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/jovyan"

# USER $NB_UID
# USER root

WORKDIR /home/jovyan

RUN chown -R jovyan /home/jovyan/ && \
    chmod 777 /home/jovyan && \ 
    chmod -R 777 /home/jovyan/software/ && \
    chmod -R 777 /home/jovyan/hetdex-notebooks/ && \
    chmod -R 777 /home/jovyan/your_classify_dir/ && \
    chmod -R 777 /home/jovyan/.config/ && \
    chmod -R 777 /home/jovyan/.cache/matplotlib/ && \
    chmod -R 777 /home/jovyan/.cache/astropy/

USER jovyan