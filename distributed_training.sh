#PBS -l walltime=06:30:00
#PBS -o distr_train__${PBS_JOBID}-o.txt
#PBS -e distr_train__${PBS_JOBID}-e.txt

nodes=$1
ppn=$2
workers=$[nodes*ppn]

j=$3
max_v=$4
rw_fac=$5
col_vel=$6
expl_rate=$7
kp=$8
xw=$9
yw=${10}
zw=${11}
lr=${12}

echo "nodes: ${nodes}"
echo "ppn: ${ppn}"
echo "workers: ${workers}"
#qsub each of the jobs

>nodes
for ((i=0; i < ${nodes}; i++))
do 
	qsub -F "${ppn} ${i} ${j} ${max_v} ${rw_fac} ${col_vel} ${expl_rate} ${kp} ${xw} ${yw} ${zw} ${lr} " nodes_full_agents.sh;
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
qsub -F "${workers} ${j} ${max_v} ${rw_fac} ${col_vel} ${expl_rate} ${kp} ${xw} ${yw} ${zw} ${lr} "  rl_algo_with agents.sh