#!/bin/bash
# Record checkpoint stats to file.
source readconfig.sh

FILENAME="$1/chkpt.log"

now="$(date +'%Y%m%d_%H%M%S')"
echo -e "\n$now checkpoint stats\n" >> $FILENAME

if [[ "$server_type" == "arcus" ]]; then
    CHKPT_RW=CHECKPOINT
    CMD_INPROGRESS='echo "stats persistence" | nc localhost 11300 | grep chkpt_in_progress | cut -d " " -f 3'
    CMD_STARTTIME='echo "stats persistence" | nc localhost 11300 | grep chkpt_start_time | cut -d " " -f 3'
    CMD_ELAPSEDTIME='echo "stats persistence" | nc localhost 11300 | grep chkpt_elapsed_time_sec | cut -d " " -f 3'
    CMD_SIZE='echo "stats persistence" | nc localhost 11300 | grep last_chkpt_snapshot_filesize_bytes | cut -d " " -f 3 | sed 's/[^0-9]//g''
    CMD_FAILURE='echo "stats persistence" | nc localhost 11300 | grep last_chkpt_failure_count | cut -d " " -f 3'
else
    CHKPT_RW=REWRITE
    CMD_INPROGRESS='echo "info persistence" | nc localhost 11300 | grep aof_rewrite_in_progress | cut -d ":" -f 2' # 1/0 
    CMD_STARTTIME='tail -n 10 $1/redis.log | grep "Background append only file rewriting started" | cut -d "*" -f 1 | cut -d "M" -f 2'
    CMD_ELAPSEDTIME='echo "info persistence" | nc localhost 11300 | grep aof_last_rewrite_time_sec | cut -d ":" -f 2'
    CMD_SIZE='echo "info persistence" | nc localhost 11300 | grep aof_base_size | cut -d ":" -f 2 | sed 's/[^0-9]//g''
    CMD_FAILURE='echo "info persistence" | nc localhost 11300 | grep aof_last_bgrewrite_status| cut -d ":" -f 2' # ok/err
fi

sleep 1
count=0
while :
do
    MPID=$(ssh -T persistence@211.249.63.38 -p ${remote} pgrep memtier)
    if [[ "${#MPID}" == "0"* ]]; then break; fi

    started=$(eval "$CMD_INPROGRESS")
    if [[ "$started" == "true"* || "$started" == "1"* ]]; then
        ((count=count+1))
        echo "$CHKPT_RW $count" >> $FILENAME
        echo "StartTime     : $(eval "$CMD_STARTTIME")" >> $FILENAME
        while :
        do
            finished=$(eval "$CMD_INPROGRESS")
            if [[ "$finished" == "false"* || "$finished" == "0"* ]]; then
                SNSHOT_SIZE=$(eval "$CMD_SIZE")
                echo "ElapsedTime   : $(eval "$CMD_ELAPSEDTIME")" >> $FILENAME
                echo "SnapshotSize  : $(($SNSHOT_SIZE/1024/1024))MB" >> $FILENAME
                echo -e "FailCount     : $(eval "$CMD_FAILURE")\n" >> $FILENAME
                break
            fi
            sleep 0.5
        done
    fi
    sleep 1
done

