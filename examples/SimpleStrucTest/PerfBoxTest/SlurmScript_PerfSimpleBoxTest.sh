#!/bin/bash

#SBATCH --job-name=SimpleBoxTest
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=1
#SBATCH --mem=1000gb
#SBATCH --distribution=cyclic:cyclic
#SBATCH --constraint=el9
#SBATCH --constraint=milan


#SBATCH --time=72:00:00
#SBATCH --output=moose_console_%j.out
#SBATCH --mail-user=robtclay@ufl.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --account=michael.tonks

echo ${SLURM_JOB_NODELIST}

MOOSE=/blue/michael.tonks/robtclay/bigprojects/macawupdated/macaw-opt
OUTPUT=/blue/michael.tonks/robtclay/bigprojects/macawupdated/examples/SimpleStrucTest/PerfBoxTest
OV_FILE=/blue/michael.tonks/robtclay/bigprojects/macawupdated/examples/SimpleStrucTest/PerfBoxTest/runtime_tols.txt

export OMPI_MCA_coll_hcoll_enable=0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/pmix/5.6.0/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/slurm/lib64/libpmi.so
export CC=mpicc CXX=mpicxx FC=mpif90 F90=mpif90 F77=mpif77
module purge
module load ufrc mkl/2025.1.0 gcc/14.2.0 openmpi/5.0.7 python/3.12 cmake/3.30.5

LINE="$(awk 'NF>0 && $1 !~ /^#/' "${OV_FILE}" | sed -n "${SLURM_ARRAY_TASK_ID}p")"


while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" == \#* ]] && continue

  
    echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID} overrides: ${LINE}"
    echo "[$(date)] Running: srun ${MOOSE} -i INPUT.i ${LINE}"
    
    cd $OUTPUT
    srun --mpi=pmix_v5 $MOOSE -i $OUTPUT/SimpleBoxTest_step2.i ${LINE}
done < "$OV_FILE"
