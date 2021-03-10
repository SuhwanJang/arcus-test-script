#!/bin/bash
source readconfig.sh

LOG_PATH=$1
FILENAME=$2
start_time="$(date '+%Y/%m/%d %H:%M:%S')"

cd $LOG_PATH

# Calculate average CPU(%)
count=0
server_SUM=0
client_SUM=0
while :
do
    sleep 2
    # Check arcus/redis CPU% 
    if [[ "$server_type" == "arcus" ]]; then
        server_top=$(top -b -n 1 | grep memcached | awk '{print $9}' | cut -d "." -f 1)
    else
        server_top=$(top -b -n 1 | grep redis | awk '{print $9}' | cut -d "." -f 1)
    fi
    if [[ $server_top ]]; then
        server_top=$(echo $server_top | awk '{print $1 + $2}')
        server_SUM=$(($server_SUM + $server_top))
        server_count=$(($server_count + 1))
        server_AVG_CPU=$(($server_SUM / $server_count))
    fi
    # Check memtier CPU%
    client_top=$(ssh -T ${client} top -b -n 1 | grep memtier | awk '{print $9}' | cut -d "." -f 1)
    if [[ $client_top ]]; then 
        client_top=$(echo $client_top | awk '{print $1 + $2}')
        client_SUM=$(($client_SUM + $client_top))
        client_count=$(($client_count + 1))
        client_AVG_CPU=$(($client_SUM / $client_count))
    fi
done

# If memtier-benchmark over...
# Calculate used memory and AVG cpu%
echo -e "\n\n3) SYSTEM RESOURCE
-------------------------------------------------------------------------------
>> Average server CPU(%) : $server_AVG_CPU%
>> Average client CPU(%) : $client_AVG_CPU%
>> TEST_TIME : $start_time ~ $(date '+%Y/%m/%d/ %H:%M:%S')
