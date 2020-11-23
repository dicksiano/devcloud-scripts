#PBS -l walltime=06:35:00
#PBS -o multi_${PBS_JOBID}-o.txt
#PBS -e multi_${PBS_JOBID}-e.txt

source activate learning-3d
cd $PBS_O_WORKDIR
echo $( pwd )


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

# Creating mpi machine file
touch ~/distributed_devcloud/nodes_file_${PBS_JOBID}


### Starting agents ###
echo "${agents} agents."
for ((i=0; i < ${agents}; i++))
do
	SPORT=$[3000 + i]
	MPORT=$[3300 + i]
	hostname >> ~/distributed_devcloud/nodes_file_${PBS_JOBID}
	echo "Server Port ${SPORT}"
	echo "Monitor Port ${MPORT}"
	#cd ..
	echo $( pwd )
	~/start_rcssserver3d.sh ${SPORT} ${MPORT} & 
	sleep 2;
	echo "Starting new agent..."
	if [ "$i" -eq  "$[agents - 1]" ]; then
	    echo "Starting last agent"
	fi
        ~/start_soccer3d_agent.sh ${SPORT} ${MPORT} ${max_v} ${radius} ${rew_radius} ${cooldown_time} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${deriv_obs} ${eval_baseline} ${num_step_same_input} true ${prior} ${alpha} ${israndom} > ~/distributed_devcloud/agent_${agents}_${j}_${i}.txt &
	echo "finishing iteration ${i}"
done 
echo "finish."
sleep 10;


### RL SERVER ###
echo "RL SERVER"
echo $( pwd )
~/devcloud-scripts/rl_algo_dist.sh ${j} ${agents} ${max_v} ${radius} ${rew_radius} ${cooldown_time} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${deriv_obs} ${eval_baseline} ${num_step_same_input} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd} ${prior} ${alpha} ${israndom} ~/distributed_devcloud/nodes_file_${PBS_JOBID}


### Killing agents ###
echo "Killing agents"
killall -9 start_soccer3d_agent.sh 
