#!/bin/bash

#SBATCH --job-name=2d_fiber_ox_halfmicron
#SBATCH --partition='milan|dev'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=500gb
#SBATCH --distribution=cyclic:cyclic

#SBATCH --time=24:00:00
#SBATCH --output=moose_console_%j.out
#SBATCH --mail-user=robtclay@ufl.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --account=michael.tonks



echo ${SLURM_JOB_NODELIST}

MOOSE=/blue/michael.tonks/robtclay/bigprojects/macawupdated/macaw-opt
OUTPUT=/blue/michael.tonks/robtclay/bigprojects/macawupdated/examples/woven_fiber_oxidation_2d/perf_step2/intwidth/halfmicron/

export OMPI_MCA_coll_hcoll_enable=0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/slurm/lib64/libpmi.so
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/pmix/5.6.0/lib
export CC=mpicc CXX=mpicxx FC=mpif90 F90=mpif90 F77=mpif77
module purge
module load ufrc mkl/2025.1.0 gcc/14.2.0 openmpi/5.0.7 python/3.12 cmake/3.30.5

cd $OUTPUT
srun --mpi=pmix_v5 $MOOSE -i $OUTPUT/step2_multi_halfmicron.i