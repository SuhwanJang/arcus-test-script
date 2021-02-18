#!/bin/bash

echo "=> Resource-recording start"

# define server IP(현재 사용중 IP를 확인해서)
server=$(hostname -I)
server="$(echo -e "${server}" | tr -d '[:space:]')"
case ${server} in
10.34.93.160) remote="11618";; # m002
10.34.91.143) remote="11617";; # m001
esac
SERVER_PID=$3
LOG_PATH=$1
FILENAME=$2
start_time="$(date '+%Y/%m/%d %H:%M:%S')"

cd $LOG_PATH
echo -e "Arcus/Redis PID : ${SERVER_PID}">> $FILENAME
before_MEM=$(pmap $SERVER_PID | grep total | awk '{print $2}' | sed 's/[^0-9]//g')

# Calculate average CPU(%)
count=0
server_SUM=0
client_SUM=0
while :
do
    sleep 2
    # Check arcus/redis CPU% 
    server_top=$(top -b -n 1 | grep ${SERVER_PID} | awk '{print $9}' | cut -d "." -f 1)
    if [[ $server_top ]]; then
        server_top=$(echo $server_top | awk '{print $1 + $2}')
        server_SUM=$(($server_SUM + $server_top))
        server_count=$(($server_count + 1))
        server_AVG_CPU=$(($server_SUM / $server_count))
    fi
    # Check memtier CPU%
    client_top=$(ssh -T persistence@211.249.63.38 -p ${remote} top -b -n 1 | grep memtier| awk '{print $9}' | cut -d "." -f 1)
    if [[ $client_top ]]; then 
        client_top=$(echo $client_top | awk '{print $1 + $2}')
        client_SUM=$(($client_SUM + $client_top))
        client_count=$(($client_count + 1))
        client_AVG_CPU=$(($client_SUM / $client_count))
    fi
    # If memtier over
    MPID=$(ssh -T persistence@211.249.63.38 -p $remote pgrep memtier)
    if [[ "${#MPID}" == "0"* ]]; then 
        after_MEM=$(pmap $SERVER_PID | grep total | awk '{print $2}' | sed 's/[^0-9]//g')
        used_MEM_K=$(($after_MEM-$before_MEM))
        break 
    fi
done

# If memtier-benchmarck over...
# Calculate used memory and AVG cpu%
echo -e "\n\n 2) RESOURCE RESULT
-------------------------------------------------------------------------------
>> Average Arcus/Redis CPU(%) : $server_AVG_CPU%
>> Average memtier     CPU(%) : $client_AVG_CPU%
>> TEST_TIME : $start_time ~ $(date '+%Y/%m/%d/ %H:%M:%S')
>> Used MEM(G) : $(($used_MEM_K/1024/1024))G\n\n\n" >> $FILENAME

# gathering all result (memtier/ chkpt/ cmdlog)
echo -e "\n\n 3) MEMTIER RESULT
-------------------------------------------------------------------------------" >> $FILENAME
cat $LOG_PATH/memtier.log | grep Ops/sec |tail -1 >> $FILENAME
cat $LOG_PATH/memtier.log | grep Totals| tail -1 >> $FILENAME
$(sed -i 's//\n/g' "$LOG_PATH/memtier.log")

if [[ -f $LOG_PATH/cmd_size.log || -f $LOG_PATH/chkpt.log ]]; then
    echo -e "\n\n 4) CHECKPOINT/REWRITE RESULT
-------------------------------------------------------------------------------" >> $FILENAME
    cat $LOG_PATH/cmd_size.log $LOG_PATH/chkpt.log >> $FILENAME
fi
echo "  :Recording done"
