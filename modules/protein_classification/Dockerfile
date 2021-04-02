FROM continuumio/miniconda3:4.8.2
LABEL description="Basic docker image containing util software requirements for the sheynkman-lab/Long-Read-Proteogenomics pipeline's SQANTI3 module"
ENV CONDA_ENV="protein_classification"

COPY environment.yml /opt/environment.yml

# Install procps so that Nextflow can poll CPU usage and
# deep clean the apt cache to reduce image/layer size
RUN apt-get update && \
    apt-get install -y \
        procps \
        build-essential && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Install the conda environment
COPY environment.yml /
RUN conda env create --quiet -f /environment.yml && conda clean -a

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name ${CONDA_ENV} > ${CONDA_ENV}.yml

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/${CONDA_ENV}/bin:$PATH

# Clone SQANTI v1.6 from release tag using the --branch flag into new folder /opt/sqanti3
RUN git clone https://github.com/ConesaLab/SQANTI3.git --branch v1.6 /opt/sqanti3 && \
    rm -rf /opt/sqanti3/.git && \
    rm -rf /opt/sqanti3/example && \
    wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred -P /opt/sqanti3/utilities/ && \
    chmod +x /opt/sqanti3/utilities/gtfToGenePred 

# Clone cDNA_Cupcake v15.1.0 from release tag using the --branch flag into new folder /opt/cDNA_Cupcake
RUN git clone https://github.com/Magdoll/cDNA_Cupcake.git --branch v15.1.0 /opt/cDNA_Cupcake && \
    cd /opt/cDNA_Cupcake && \
    python setup.py build && \
    python setup.py install && \
    rm -rf /opt/cDNA_Cupcake/.git && \
    rm -rf /opt/cDNA_Cupcake/.git

ENV PYTHONPATH /opt/cDNA_Cupcake/sequence/
ENV PYTHONPATH "$PYTHONPATH:/opt/sqanti3/"
# ENV PATH "$PATH:/opt/sqanti3/"


# # Copy additional scripts from bin and add to PATH
# RUN mkdir /opt/bin
COPY src/* /opt/sqanti3/
RUN chmod +x /opt/sqanti3/*
ENV PATH="$PATH:/opt/sqanti3/"




# FROM continuumio/miniconda3:4.8.2
# LABEL description="Base docker image with conda and util libraries"
# ARG ENV_NAME="protein_classification"

# # Install mamba for faster installation in the subsequent step
# # Install r-base for being able to run the install.R script
# RUN conda install -c conda-forge mamba r-base -y

# # Install procps so that Nextflow can poll CPU usage and
# # deep clean the apt cache to reduce image/layer size
# RUN apt-get update \
#  && apt-get install -y procps \
#  && apt-get clean -y && rm -rf /var/lib/apt/lists/*
 
# # Install the conda environment
# COPY environment.yml /
# RUN mamba env create --quiet --name ${ENV_NAME} --file /environment.yml && conda clean -a

# # Install R packages that are possibly not available via conda
# # COPY bin/install.R /
# # RUN Rscript /install.R

# # Add conda installation dir to PATH (instead of doing 'conda activate')
# ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

# # Dump the details of the installed packages to a file for posterity
# RUN mamba env export --name ${ENV_NAME} > ${ENV_NAME}_exported.yml


# RUN git clone https://github.com/Magdoll/cDNA_Cupcake.git --branch v15.1.0 /opt/cDNA_Cupcake && \
#     cd /opt/cDNA_Cupcake && \
#     python setup.py build && \
#     python setup.py install && \
#     rm -rf /opt/cDNA_Cupcake/.git && \
#     rm -rf /opt/cDNA_Cupcake/.git
# ENV PYTHONPATH /opt/cDNA_Cupcake/sequence/
# # Add conda installation dir to PATH (instead of doing 'conda activate')
# ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

# # Copy additional scripts from bin and add to PATH
# RUN mkdir /opt/bin
# COPY modules/*/src/* /opt/bin/
# RUN chmod +x /opt/bin/*
# ENV PATH="$PATH:/opt/bin/"
