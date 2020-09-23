#PBS -l walltime=06:30:00
#PBS -o rlalgodist_${PBS_JOBID}-o.txt
#PBS -e rlalgodist_${PBS_JOBID}-e.txt


### Inputs ###
j=$1
agents=$2


# Agent #
max_v=$3
radius=$4
rew_radius=$5
cooldown_time=$6
rw_fac=$7
col_vel=$8
kp=$9
xw=${10}
yw=${11}
zw=${12}
deriv_obs=${13}
eval_baseline=${14}
num_step_same_input=${15}

# Neural Net #
sched=${16}
hid_size=${17}
num_hid_layers=${18}
expl_rate=${19}

# PPO #
max_timesteps=${20}
timesteps_per_ab=${21}
clip_param=${22}
ent_coeff=${23}
epochs=${24}
lr=${25}
batch_s=${26}
gamma=${27}
lambd=${28}

# Node file
file=${29}

cd $PBS_O_WORKDIR
cd ~/ddpg-humanoid
source activate learning-3d

echo $( pwd )
echo ${agents}
echo ${max_timesteps}
echo ${file}
mpirun -n ${agents} -machinefile ${file}  python -m baselines.ppo1.run_soccer --num-timesteps=${max_timesteps}
