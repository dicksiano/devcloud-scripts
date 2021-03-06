#PBS -l walltime=06:30:00
#PBS -o rlalgoagents__${PBS_JOBID}-o.txt
#PBS -e rlalgoagents__${PBS_JOBID}-e.txt

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
	
	~/start_soccer3d_agent.sh ${SPORT} ${MPORT} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} true > ~/distributed_devcloud/agent_${j}_4_${i}.txt &
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
~/devcloud-scripts/rl_algo_dist.sh ${j} ${totalworkers} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd} ~/distributed_devcloud/nodes
