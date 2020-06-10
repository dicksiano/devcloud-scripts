#PBS -l walltime=06:30:00
#PBS -o distr_train__${PBS_JOBID}-o.txt
#PBS -e distr_train__${PBS_JOBID}-e.txt

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

echo "nodes: ${nodes}"
echo "ppn: ${ppn}"
echo "workers: ${workers}"
#qsub each of the jobs

>nodes
for ((i=0; i < ${nodes}; i++))
do 
	qsub -F "${ppn} ${i} ${j} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd} " nodes_full_agents.sh;
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


echo "total of ${workers} workers."
sleep 30
qsub -F "${j} ${workers} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} ${sched} ${hid_size} ${num_hid_layers} ${expl_rate} ${max_timesteps} ${timesteps_per_ab} ${clip_param} ${ent_coeff} ${epochs} ${lr} ${batch_s} ${gamma} ${lambd}"  rl_algo_with agents.sh