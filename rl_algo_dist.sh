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

### RW DEFINITION: WITH OR WITHOUT PRIORS ###
prior=${29}
### ALPHA
alpha=${30}
### RANDOM
israndom=${31}
initialrandom=${32}
logstate=${33}

# Node file
file=${34}


cd $PBS_O_WORKDIR
cd ~/ddpg-humanoid
source activate learning-3d

echo $( pwd )
echo ${agents}
echo ${max_timesteps}
echo ${file}
mpirun -n ${agents} -machinefile ${file}  python -m baselines.ppo1.run_pushrecovery \
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
                                                    --num_hid_layers=${num_hid_layers} \
                                                    --radius=${radius} \
                                                    --reward_radius=${rew_radius} \
                                                    --cooldown_time=${cooldown_time} \
                                                    --derivative=${deriv_obs} \
                                                    --eval_basel=${eval_baseline} \
                                                    --num_t_same_input=${num_step_same_input} \
                                                    --prior=${prior} \
                                                    --alpha=${alpha} \
                                                    --is_random=${israndom} \
                                                    --initialrandom=${initialrandom} \
                                                    --logstate=${logstate} #  \
                           #                         --load-model \
						   # --model-dir=logs/20201120-092016_0/model      #CP0

						   # --model-dir=logs/20201124-190602_0/model      #CPrand
                                                   # --model-dir=logs/20201120-052328_0/model      #CP0
                                                   # --model-dir=logs/20201124-165235_0/model      #CP90
                                                   # --model-dir=logs/20201124-175710_0/model      #CP-90
