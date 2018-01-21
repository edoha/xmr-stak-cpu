#!/bin/bash

#---------------------------------------------------------------------------

function KillPID() {
	CMD="kill -9 $1"
	echo $CMD
	exec $CMD &
}

#---------------------------------------------------------------------------

function CheckPIDs() {
	
	PROCESS_CMD=$1
	
	echo "Checking $PROCESS_CMD Processes ..."	

	pid_count=0

	for pid in `ps -ef | grep -v grep | grep "$PROCESS_CMD" | awk '{print $2}'` ;
	do 
		let "pid_count++";
	done
	
	echo "$pid_count Active Processes ($PROCESS_CMD)"
		
	if [ $pid_count -eq 1 ]
	then
		for pid in `ps -ef | grep -v grep | grep "$PROCESS_CMD" | awk '{print $2}'` ;
		do
			KillPID $pid;
		done
	elif [ $pid_count -gt 1 ]
	then
		for pid in `ps -ef | grep -v grep | grep "$PROCESS_CMD" | awk '{print $2}'` ;
		do
			KillPID $pid;
		done
	fi
	
}

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

MINER_PS="/miner/xmr-stak-cpu/bin/xmr-stak-cpu"

MINER_LOG="/miner/out.log"
SUB_STRING="Totals:"

HASH_THRESHOLD=25
DO_SHUTDOWN=0

while IFS= read -r STRING
do
	if [[ $STRING == *"$SUB_STRING"* ]]; then		
		echo $STRING
		set $STRING
		#echo $2
		gt=$(echo "$2 > $HASH_THRESHOLD" | bc -q )
		if [[ $gt = 0 ]]; then			
			echo $STRING "($2)"
			CheckPIDs $MINER_PS
			DO_SHUTDOWN=1
			break
		fi
	fi
	
done <"$MINER_LOG"

if [[ $DO_SHUTDOWN == 1 ]]; then
	CMD="sudo shutdown now"
	echo $CMD
	exec $CMD &
fi


