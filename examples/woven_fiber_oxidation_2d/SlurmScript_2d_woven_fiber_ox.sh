#!/bin/bash

#SBATCH --job-name=2d_fiber_ox
#SBATCH --partition=hpg2-compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=124gb
#SBATCH --distribution=cyclic:cyclic

#SBATCH --time=2:00:00
#SBATCH --output=moose_console_%j.out
#SBATCH --mail-user=robtclay@ufl.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --account=michael.tonks



echo ${SLURM_JOB_NODELIST}

MOOSE=/blue/michael.tonks/robtclay/bigprojects/macawupdated/macaw-opt
OUTPUT=/blue/michael.tonks/robtclay/bigprojects/macawupdated/examples/woven_fiber_oxidation_2d/step2/

export CC=mpicc CXX=mpicxx FC=mpif90 F90=mpif90 F77=mpif77
module purge
module load ufrc mkl/2023.2.0 gcc/12.2.0 openmpi/4.1.6 python/3.11 cmake/3.26.4

cd $OUTPUT
srun --mpi=pmix_v3 $MOOSE -i $OUTPUT/step2_multi.i