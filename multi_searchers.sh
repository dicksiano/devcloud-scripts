#PBS -l walltime=00:35:00
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
        ~/start_soccer3d_agent.sh ${SPORT} ${MPORT} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} true > ~/distributed_devcloud/agent_${agents}_${j}_${i}.txt &
	echo "finishing iteration ${i}"
done 
echo "finish."
sleep 10;


### RL SERVER ###
echo "RL SERVER"
echo $( pwd )
~/distributed_devcloud/rl_algo_dist.sh ${j} ${agents} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd} ~/distributed_devcloud/nodes_file_${PBS_JOBID}


### Killing agents ###
echo "Killing agents"
killall -9 start_soccer3d_agent.sh 