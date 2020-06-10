#PBS -l walltime=06:30:00
#PBS -o rl_algo__${PBS_JOBID}-o.txt
#PBS -e rl_algo__${PBS_JOBID}-e.txt

workers=$1
j=$2
max_v=$3
rw_fac=$4
col_vel=$5
expl_rate=$6
kp=$7
xw=$8
yw=$9
zw=${10}
lr=${11}

plusworkers=10
totalworkers=$((workers+plusworkers))

for ((i=0; i < 10; i++))
do
	SPORT=$[3000 + i]
	MPORT=$[3300 + i]
	
    hostname >> ~/distributed_devcloud/nodes
	
    echo "Server Port ${SPORT}"
	echo "Monitor Port ${MPORT}"
	echo $( pwd )
	
    ~/start_rcssserver3d.sh ${SPORT} ${MPORT} & 
	sleep 2;
	
    ~/start_soccer3d_agent.sh ${SPORT} ${MPORT} ${max_v} ${rw_fac} ${col_vel} ${kp} ${xw} ${yw} ${zw} true > ~/distributed_devcloud/agent_${j}_4_${i}.txt &
	echo "finishing iteration ${i}"
done 
echo "finish."


sleep 30
cd ~/distributed_devcloud
qsub -F "${totalworkers} ${j} ${max_v} ${rw_fac} ${col_vel} ${expl_rate} ${kp} ${xw} ${yw} ${zw} ${lr} "  start_rl_server.sh