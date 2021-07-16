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
    'astropy' \
    'astropy-healpix' \
    'astrowidgets' \
    'astroquery' \ 
    'beautifulsoup4' \
    'conda-forge::blas=*=openblas' \
    'bokeh' \
    'bottleneck' \
    'cloudpickle' \
    'cython' \
    'dask' \
    'dill' \
    'extinction' \
    'healpy' \
    'h5py' \
    'ipywidgets' \
    'ipympl'\
    'matplotlib-base' \
    'numba' \
    'numexpr' \
    'pandas' \
    'patsy' \
    'plotly' \
    'photutils' \
    'protobuf' \
    'pytables' \
    'python-kaleido' \
    'regions' \
    'reproject' \
    'scikit-image' \
    'scikit-learn' \
    'scipy' \
    'seaborn' \
    'sep' \
    'specutils' \
    'widgetsnbextension'\
    && \
    conda clean --all -f -y && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    # Check this URL for most recent compatibilities
    # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    # jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
    jupyter lab build -y --dev-build=False --minimize=False && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/jovyan/.cache/yarn" && \
    rm -rf "/home/jovyan/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \ 
    fix-permissions "/home/jovyan"

# pip install packages that don't have conda installs
RUN pip install speclite==0.8 && \
    pip install --extra-index-url https://gate.mpe.mpg.de/pypi/simple/ pyhetdex && \
    pip install agavepy && \
    pip install dustmaps && \
    pip install nway

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

WORKDIR /home/jovyan

RUN chown -R jovyan /home/jovyan/ && \
    chmod 777 /home/jovyan && \ 
    chmod -R 777 /home/jovyan/software/ && \
    chmod -R 777 /home/jovyan/hetdex-notebooks/ && \
    chmod -R 777 /home/jovyan/your_classify_dir/ && \
    chmod -R 777 /home/jovyan/.config/ && \
    chmod -R 777 /home/jovyan/.cache/matplotlib/ && \
    chmod -R 777 /home/jovyan/.cache/

USER jovyan