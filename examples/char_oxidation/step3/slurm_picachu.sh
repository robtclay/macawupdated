#!/bin/sh
#SBATCH --job-name=step3                 #Job name
#SBATCH --nodes=2                        #Number of nodes (servers, 32 proc/node)
#SBATCH --ntasks=64                      #Number of tasks/MPI RankS
#SBATCH --ntasks-per-node=32             #Tasks per node
#SBATCH --ntasks-per-socket=8            #Tasks per socket
#SBATCH --cpus-per-task=1                #Number of CPU per task
#SBATCH --mem-per-cpu=3600mb             #Memory (120 gig/server)
#SBATCH --distribution=cyclic:cyclic     #Distribute tasks cyclically
#SBATCH --time=4-00:00:00                  #Walltime days-hh:mm:ss
#SBATCH --output=moose-%j.out            #Output and error log
#SBATCH --mail-type=END,FAIL             #When to email user
#SBATCH --mail-user=msessim@ufl.edu      #Email address to send mail to
#SBATCH --account=michael.tonks          #Allocation group name, add -b for burst job
#SBATCH --qos=michael.tonks-b            #Burst

srun --mpi=pmix_v3 ~/projects/picachu/picachu-opt -i step3_char_transient_aux.i
