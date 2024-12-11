#!/bin/bash

#SBATCH --job-name=3d_fiber_ox
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
OUTPUT=/blue/michael.tonks/robtclay/bigprojects/macawupdated/examples/3d_woven_fiber_ox/step2/

export CC=mpicc CXX=mpicxx FC=mpif90 F90=mpif90 F77=mpif77
module purge
module load ufrc mkl/2023.2.0 gcc/12.2.0 openmpi/4.1.6 python/3.11 cmake/3.26.4

cd $OUTPUT
srun --mpi=pmix_v3 $MOOSE -i $OUTPUT/step2_multi.i