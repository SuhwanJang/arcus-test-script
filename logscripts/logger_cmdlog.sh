#!/bin/bash
source readconfig.sh

#initialize
FILENAME="$1/cmd_size.log"

# Record checkpoint stats to file.
if [[ "$server_mode" == "off" ]];then
    echo "persistence(AOF) off"
    exit 0
fi

now="$(date +'%Y%m%d_%H%M%S')"
echo -e "\n$now recording cmdlog start\n" >> $FILENAME

if [[ "$server_type" == "arcus" ]];then #ARCUS
    CMD_CURRITEM='echo "stats" | nc localhost 11300 | grep curr_items | cut -d " " -f 3| sed 's/[^0-9]//g''
    CMD_CMDLOG_SIZE='echo "stats persistence" | nc localhost 11300 | grep current_command_log_filesize_bytes | cut -d " " -f 3 | sed 's/[^0-9]//g''
else # Redis
    CMD_CURRITEM='echo "info keyspace" | nc localhost 11300 | grep keys | cut -d "=" -f 2 | cut -d "," -f 1 | sed 's/[^0-9]//g''
    CMD_CMDLOG_SIZE='echo "info persistence" | nc localhost 11300 | grep aof_current_size | cut -d ":" -f 2 | sed 's/[^0-9]//g''
fi

pre_PRCNT=0
count=0
sum=0

while :
do
    sleep 2
    MPID=$(ssh -T persistence@211.249.63.38 -p ${remote} pgrep memtier)
    if [[ "${#MPID}" == "0"* ]]; then break; fi
    
    # record cmdlogsize per 5%

    curritem=$(eval "$CMD_CURRITEM")
    cmdlog_size=$(eval "$CMD_CMDLOG_SIZE")
    PRCNT=$(($curritem*100/$keymaximum))
    modulo=$(($PRCNT%5))
    if [[ $modulo -eq 0 ]]; then  
        count=$(($count + 1))
        if [[ $pre_PRCNT -eq $PRCNT ]]; then
            sum=$(($sum + $cmdlog_size))
        else            
            pre_PRCNT=$PRCNT
            sum=$cmdlog_size
        fi    
    fi
    if [[ $count -ne 0 && $modulo -ne 0 ]]; then
        echo "AVG: ($pre_PRCNT%): $(($sum/$count/1024/1024))MB" >> $FILENAME
        count=0
    fi
done

if [[ $count -ne 0 ]]; then
    echo "AVG: ($pre_PRCNT%): $(($sum/$count/1024/1024))MB" >> $FILENAME
fi

