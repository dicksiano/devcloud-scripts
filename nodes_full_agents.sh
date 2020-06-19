#PBS -l walltime=08:00:00
#PBS -o fullagents_${PBS_JOBID}-o.txt
#PBS -e fullagents_${PBS_JOBID}-e.txt

### Inputs ###
processes=$1
node=$2
j=$3

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

cd $PBS_O_WORKDIR
echo $( pwd )

echo "${processes} processes."
for ((i=0; i < ${processes}; i++))
do
	SPORT=$[3000 + i + node*processes]
	MPORT=$[3300 + i + node*processes]

	hostname >> ~/distributed_devcloud/nodes
	
	echo "Server Port ${SPORT}"
	echo "Monitor Port ${MPORT}"
	echo $( pwd )
	
	cd --
	~/start_rcssserver3d.sh ${SPORT} ${MPORT} & 
	sleep 2;

	if [ "$i" -eq  "$[processes - 1]" ]; then
		echo "Starting last agent"
           	~/start_soccer3d_agent.sh ${SPORT} ${MPORT} ${max_v} ${radius} ${rew_radius} ${cooldown_time} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${deriv_obs} ${eval_baseline} ${num_step_same_input} true > ~/distributed_devcloud/agent_${processes}_${j}_${node}_${i}.txt
    	else
		~/start_soccer3d_agent.sh ${SPORT} ${MPORT} ${max_v} ${radius} ${rew_radius} ${cooldown_time} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${deriv_obs} ${eval_baseline} ${num_step_same_input} true > ~/distributed_devcloud/agent_${processes}_${j}_${node}_${i}.txt &
    	fi	
	sleep 2;
	echo "finishing iteration ${i}"
done 
echo "finish."
