#PBS -o rlalgo_${PBS_JOBID}-o.txt
#PBS -e rlalgo_${PBS_JOBID}-e.txt


### Inputs ###
j=$1
agents=$2


# Agent #
max_v=$3
rw_fac=$4
col_vel=$5
kp=$6
xw=$7
yw=$8
zw=$9


# Neural Net #
sched=${10}
hid_size=${11}
num_hid_layers=${12}
expl_rate=${13}


# PPO #
max_timesteps=${14}
timesteps_per_ab=${15}
clip_param=${16}
ent_coeff=${17}
epochs=${18}
lr=${19}
batch_s=${20}
gamma=${21}
lambd=${22}

# Node file
file=${23}

cd $PBS_O_WORKDIR
cd ~/ddpg-humanoid
source activate learning-3d

echo $( pwd )
echo ${agents}
echo ${max_timesteps}
echo ${nodes}
mpirun -n ${agents} -machinefile ${file}  python -m baselines.ppo1.run_soccer \
                                                    --learning_rate=${lr} \
                                                    --timesteps_per_actorbatch=${timesteps_per_ab} \
                                                    --batch_size=${batch_s} \
                                                    --num_timesteps=${max_timesteps} \
                                                    --kp=${kp} \
                                                    --xw=${xw} \
                                                    --yw=${yw} \
                                                    --zw=${zw} \
                                                    --max_vel=${max_v} \
                                                    --reward_factor=${rw_fac} \
                                                    --collision_vel=${col_vel} \
                                                    --exploration_rate=${expl_rate} \
                                                    --schedule=${sched} \
                                                    --hid_siz=${hid_size} \
                                                    --clip_param=${clip_param} \
                                                    --ent_coeff=${ent_coeff} \
                                                    --epochs=${epochs} \
                                                    --gamma=${gamma} \
                                                    --lambd=${lambd} \
                                                    --num_hid_layers=${num_hid_layers}