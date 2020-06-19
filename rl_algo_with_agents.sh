#PBS -l walltime=06:30:00
#PBS -o rlalgoagents__${PBS_JOBID}-o.txt
#PBS -e rlalgoagents__${PBS_JOBID}-e.txt

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

plusworkers=50
totalworkers=$((agents+plusworkers))

for ((i=0; i < ${plusworkers}; i++))
do
	SPORT=$[3000 + i + agents ]
	MPORT=$[3300 + i + agents ]
	
	hostname >> ~/distributed_devcloud/nodes
	
	echo "Server Port ${SPORT}"
	echo "Monitor Port ${MPORT}"
	echo $( pwd )
	
	cd --
	~/start_rcssserver3d.sh ${SPORT} ${MPORT} & 
	sleep 2;
	
	~/start_soccer3d_agent.sh ${SPORT} ${MPORT} ${max_v} ${radius} ${rew_radius} ${cooldown_time} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${deriv_obs} ${eval_baseline} ${num_step_same_input} true > ~/distributed_devcloud/agent_${j}_4_${i}.txt &
	echo "finishing iteration ${i}"
done 
echo "finish."


## Sanity check
# wait for all agents to connect
up_agents=0
time=0

while [ $up_agents -ne $totalworkers ]
do
 up_agents=`ls -lR ~/distributed_devcloud/agent_*.txt | wc -l`
 echo "waiting for agents to connect.. time:" $(($time/600))"min"
 echo "$up_agents/${totalworkers} already up."
 sleep 15
 let "time=time+15"
done
echo "all agents up!"


### RL SERVER ###
sleep 10;
echo "RL SERVER"
echo $( pwd )
echo "Total agents"
echo ${totalworkers}
cd ~/devcloud-scripts/
~/devcloud-scripts/rl_algo_dist.sh ${j} ${totalworkers} ${max_v} ${radius} ${rew_radius} ${cooldown_time} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${deriv_obs} ${eval_baseline} ${num_step_same_input} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd} ~/distributed_devcloud/nodes
