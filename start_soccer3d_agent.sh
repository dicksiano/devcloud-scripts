#PBS -e ~/devcloud-scripts/startsoccer3d_${PBS_JOBID}-e.txt
source activate learning-3d
cd ~/soccer3d/binaries
export LC_ALL=C
./SoccerAgentServer_Main  --horizon-size=20000 --server-port=$1 --monitor-port=$2 --max-vel=$3 --radius=$4 --rw-radius=$5 --cooldown-time=$6 --reward-factor=$7 --collision-vel=$8 --kp=$9 --xw=${10} --yw=${11} --zw=${12} --derivative-obs=${13} --evaluate-baseline=${14} --num-steps-same-input=${15} --parallel-train=${16} --prior=${17} --collision-alpha=${18} --random=${19}
#./SoccerAgentServer_Main --server-port=$1 --monitor-port=$2 --task-number=2 --min-height=${17}
