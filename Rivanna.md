1. Setup

```
cd /project/sheynkmanlab
git clone git@github.com:sheynkman-lab/Long-Read-Proteogenomics.git
```

2. Develop

* Update code in `/project/sheynkmanlab/Long-Read-Proteogenomics`
* Debug/test code modification in ijob on single node (local mode)

```
ijob -p standard -c 4 -A sheynkmanlab --mem=36G -t 4:00:00 
```
```
module purge
ml singularity nextflow/20.10.0
export SINGULARITY_CACHEDIR=/scratch/$USER/singularity_cache #this could also be in home or project storage 
export NXF_SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR
mkdir -p $SINGULARITY_CACHEDIR

# setup debugging run from local code repo instead of container images
CODEDIR=/project/sheynkmanlab/Long-Read-Proteogenomics
export SINGULARITYENV_PREPEND_PATH=$CODEDIR/modules/filter_sqanti/src/ 

nextflow run $CODEDIR -config -profile test,cluster --max_cpus=2 --max_memory=18G
```

3.	Production Run

a.	Local mode

b.	SLURM executor

