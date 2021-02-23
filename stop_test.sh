#!bin/sh
source readconfig.sh

if [[ "$server_mode" != "off" ]]; then
    chkpt_inprogress='echo "stats persistence" | nc localhost 11300 | grep chkpt_in_progress | cut -d " " -f 3'
    if [[ "$server_type" == "redis" ]]; then
        chkpt_inprogress='echo "info persistence" | nc localhost 11300 | grep aof_rewrite_in_progress | cut -d ":" -f 2' # 0 or 1
    fi
    while :
    do
        check=$(eval "$chkpt_inprogress")
        if [[ "$check" == "true"* || "$check" == "1"* ]]; then
            echo "checkpoint(rewrite) inprogress.. wait"
        else
            break;
        fi
        sleep 3
    done
fi

waittime=3
PID=$(ps -ef | grep $USER | grep -v "grep" | grep memtier | grep $port | awk '{print $2}')
if [[ ${PID} ]]; then $(kill ${PID}); echo " => memtier($PID) killed"; waittime=10; fi

if [[ "$server_type" == "arcus" ]]; then
    PID=$(ps -ef | grep $USER | grep -v "grep" | grep memcached | grep $port | awk '{print $2}')
    if [[ ${PID} ]]; then $(kill ${PID}); echo " => arcus($PID) killed"; waittime=10; fi
else
    PID=$(ps -ef | grep $USER | grep -v "grep" | grep redis | grep $port | awk '{print $2}')
    if [[ ${PID} ]]; then $(kill ${PID}); echo " => redis($PID) killed"; waittime=10; fi
fi

PID=$(ps -ef | grep $USER | grep -v "grep" | grep bash | grep logger_chkpt | awk '{print $2}')
if [[ ${PID} ]]; then $(kill ${PID}); echo " => logger_chkpt.sh($PID) killed"; fi

PID=$(ps -ef | grep $USER | grep -v "grep" | grep bash | grep logger_cmdlog | awk '{print $2}')
if [[ ${PID} ]]; then $(kill ${PID}); echo " => logger_cmdlog.sh($PID) killed"; fi

PID=$(ps -ef | grep $USER | grep -v "grep" | grep bash | grep logger_resource | awk '{print $2}')
if [[ ${PID} ]]; then $(kill ${PID}); echo " => logger_resource.sh($PID) killed"; fi

sleep $waittime

alive1=$(ps -ef | grep $USER | grep -v "grep" | grep -v "stop_test" | grep $port | awk '{print $2}')
alive2=$(ps -ef | grep $USER | grep -v "grep" | grep "bash" | grep logger_ | awk '{print $2}')

if [[ $alive1 || $alive2 ]]; then
    echo "some test processes are not killed. $alive1 $alive2"
fi
