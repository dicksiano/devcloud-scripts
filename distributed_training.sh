#PBS -l walltime=09:30:00
#PBS -o distr_train__${PBS_JOBID}-o.txt
#PBS -e distr_train__${PBS_JOBID}-e.txt

### Inputs ###
nodes=$1
ppn=$2
hash=$3


# Agent #
max_v=$4
radius=$5
rew_radius=$6
cooldown_time=$7
rw_fac=$8
col_vel=$9
kp=${10}
xw=${11}
yw=${12}
zw=${13}
deriv_obs=${14}
eval_baseline=${15}
num_step_same_input=${16}

# Neural Net #
sched=${17}
hid_size=${18}
num_hid_layers=${19}
expl_rate=${20}

# PPO #
max_timesteps=${21}
timesteps_per_ab=${22}
clip_param=${23}
ent_coeff=${24}
epochs=${25}
lr=${26}
batch_s=${27}
gamma=${28}
lambd=${29}



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

	qsub -F "${ppn} ${i} ${hash} ${max_v} ${radius} ${rew_radius} ${cooldown_time} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${deriv_obs} ${eval_baseline} ${num_step_same_input} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd} " nodes_full_agents.sh;
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
qsub -F "${hash} ${workers} ${max_v} ${radius} ${rew_radius} ${cooldown_time} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${deriv_obs} ${eval_baseline} ${num_step_same_input} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd}"  rl_algo_with_agents.sh
