1. Setup

```
cd /project/sheynkman
git clone git@github.com:sheynkman-lab/Long-Read-Proteogenomics.git
```

2. Interactive Development

Update code in `/project/sheynkman/Long-Read-Proteogenomics`. Then debug/test code modification in ijob on single node (local mode).

Adjust cores, memory and time as needed. Number of cores should be >= max_cpus set in the profile/config to be used. Default memory allocation is ~9GB per cpu core.
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
CODEDIR=/project/sheynkman/Long-Read-Proteogenomics
# prepend the PATH variable so executables will be searched for in the local repo first
export SINGULARITYENV_PREPEND_PATH=$CODEDIR/modules/filter_sqanti/src/ 

mkdir -p /scratch/$USER/nextflow-runs
cd /scratch/$USER/nextflow-runs
nextflow run $CODEDIR -profile test -with-singularity -without-docker
```

Alternatively run with cluster SLURM executor:
```
nextflow run $CODEDIR -profile test,cluster
```
The `cluster` profile includes the conf/cluster.config file which sets the SLURM executor. Since Docker processes cannot be executed on the HPC platform, the conf/cluster.config file enables Singularity and disables Docker as presets.  Therefore the explicit `-with-singularity -without-docker` command line options are not needed.

When satisfied with code, push changes to remote repo, rebuild container images, and push images to DockerHub..

3. Interactive Production Run

For production runs (local mode and SLURM executor), nextflow will pull the sheynkman-lab/Long-Read-Proteogenomics Docker container image. Local code repositories should be ignored so the `SINGULARITYENV_PREPEND_PATH` environment variable should be unset.

a. Local mode

Adjust cores, memory and time as needed. Number of cores should be >= max_cpus set in the profile/config to be used. Default memory allocation is ~9GB per cpu core.
```
ijob -p standard -c 4 -A sheynkmanlab --mem=36G -t 4:00:00
```
```
module purge
ml singularity nextflow/20.10.0
export SINGULARITY_CACHEDIR=/scratch/$USER/singularity_cache #this could also be in home or project storage
export NXF_SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR
mkdir -p $SINGULARITY_CACHEDIR

mkdir -p /scratch/$USER/nextflow-runs
cd /scratch/$USER/nextflow-runs
nextflow run sheynkman-lab/Long-Read-Proteogenomics -profile test -with-singularity -without-docker
```

b. SLURM executor
```
nextflow run sheynkman-lab/Long-Read-Proteogenomics -profile test,cluster
```

4. Non-interactive Production Run

Create the `nextflow.slurm` SLURM job script:
```
#!/bin/bash
#SBATCH -A sheynkmanlab    # or use sheynkmanlab_paid
#SBATCH -p standard
#SBATCH -c 1               # we just need a single core for managing the main nextflow process
#SBATCH -t 8:00:00         # increase time as needed to complete entire pipeline
#SBATCH -o nextflow-%j.out
#SBARCH -e nextflow-%j.err

module purge
ml singularity nextflow/20.10.0
export SINGULARITY_CACHEDIR=/scratch/$USER/singularity_cache #this could also be in home or project storage
export NXF_SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR
mkdir -p $SINGULARITY_CACHEDIR

mkdir -p /scratch/$USER/nextflow-runs
cd /scratch/$USER/nextflow-runs

nextflow run sheynkman-lab/Long-Read-Proteogenomics -profile test,cluster
```

Submit the job script from a frontend like so:
```
sbatch nextflow.slurm
```
