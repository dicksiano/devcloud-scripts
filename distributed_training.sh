#PBS -l walltime=06:30:00
#PBS -o distr_train__${PBS_JOBID}-o.txt
#PBS -e distr_train__${PBS_JOBID}-e.txt

### Inputs ###
nodes=$1
ppn=$2
hash=$3

# Agent #
max_v=$4
rw_fac=$5
col_vel=$6
kp=$7
xw=$8
yw=$9
zw=${10}

# Neural Net #
sched=${11}
hid_size=${12}
num_hid_layers=${13}
expl_rate=${14}

# PPO #
max_timesteps=${15}
timesteps_per_ab=${16}
clip_param=${17}
ent_coeff=${18}
epochs=${19}
lr=${20}
batch_s=${21}
gamma=${22}
lambd=${23}


workers=$[nodes*ppn]
echo "nodes: ${nodes}"
echo "ppn: ${ppn}"
echo "workers: ${workers}"
#qsub each of the jobs


touch ~/distributed_devcloud/nodes
lines_nodes=0
time=0
expected=0

for ((i=0; i < ${nodes}; i++))
do 
	expected=$[i*ppn]
	while [ $lines_nodes -ne $expected ]
	do
		lines_nodes=`wc -l < ~/distributed_devcloud/nodes`
		 echo "waiting for agents to write.. time:" $(($time/600))"min"
		 echo "$lines_nodes/${expected} already up."
		 sleep 15
		let "time=time+15"
	done
	echo "all agents haven written!"

	qsub -F "${ppn} ${i} ${hash} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd} " nodes_full_agents.sh;
	sleep 35; 
done;

#wait for all nodes to allocate
allocated=0
time=0

while [ $allocated -ne $nodes ]
do
	allocated=`qstat -r | grep "R " | wc -l`
	echo "waiting for allocated nodes.. time:" $(($time/600))"min"
	echo "$allocated/${nodes} already allocated."
	sleep 10 
	let "time=time+10"
done
echo "all nodes allocated."


#wait for all agents to connect
up_agents=0
time=0

while [ $up_agents -ne $workers ]
do
 up_agents=`ls -lR ~/distributed_devcloud/agent_*.txt | wc -l`
 echo "waiting for agents to connect.. time:" $(($time/600))"min"
 echo "$up_agents/${workers} already up."
 sleep 15
 let "time=time+15"
done
echo "all agents up!"


echo "total of ${workers} workers."
qsub -F "${hash} ${workers} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd}"  rl_algo_with_agents.sh
