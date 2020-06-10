#PBS -l walltime=08:00:00
#PBS -o fullagents_${PBS_JOBID}-o.txt
#PBS -e fullagents_${PBS_JOBID}-e.txt

### Inputs ###
processes=$1
node=$2
j=$3

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

cd $PBS_O_WORKDIR
echo $( pwd )

echo "${processes} processes."
for ((i=0; i < ${processes}; i++))
do
	SPORT=$[3000 + i + node*processes]
	MPORT=$[3300 + i + node*processes]

	hostname >> >> ~/distributed_devcloud/nodes
	
    echo "Server Port ${SPORT}"
	echo "Monitor Port ${MPORT}"
	echo $( pwd )
	
    ~/start_rcssserver3d.sh ${SPORT} ${MPORT} & 
	sleep 2;
	
    ~/start_soccer3d_agent.sh ${SPORT} ${MPORT} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} true > ~/distributed_devcloud/agent_${processes}_${j}_${i}.txt &
	sleep 2;
	echo "finishing iteration ${i}"
done 
echo "finish."