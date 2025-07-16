#!/bin/bash

#SBATCH --job-name=Pica_char_ox
#SBATCH --nodes=16
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8GB
#SBATCH --distribution=cyclic:cyclic

#SBATCH --time=72:00:00
#SBATCH --output=moose_console_%j.out
#SBATCH --mail-user=robtclay@ufl.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --account=michael.tonks
#SBATCH --qos=michael.tonks-b

echo ${SLURM_JOB_NODELIST}

MOOSE=/blue/michael.tonks/robtclay/bigprojects/macawupdated/macaw-opt
OUTPUT=/blue/michael.tonks/robtclay/bigprojects/macawupdated/examples/char_oxidation/step3

export OMPI_MCA_coll_hcoll_enable=0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/slurm/lib64/libpmi.so
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/pmix/5.6.0/lib
export CC=mpicc CXX=mpicxx FC=mpif90 F90=mpif90 F77=mpif77
module purge
module load ufrc mkl/2025.1.0 gcc/14.2.0 openmpi/5.0.7 python/3.12 cmake/3.30.5

cd $OUTPUT
srun --mpi=pmix_v5 $MOOSE -i $OUTPUT/step3_char_transient.i