#!bin/sh

if [[ $# -eq 0 ]] 
    then read -r -p "Enter port-number : " port
    else port=$1
fi

waittime=3
PID=$(ps -ef | grep $USER | grep -v "grep" | grep logger_chkpt | awk '{print $2}')
if [[ ${PID} -ne 0 ]]; then echo " =>logger_chkpt($PID) kill"; $(kill -9 ${PID}); fi

PID=$(ps -ef | grep $USER | grep -v "grep" | grep logger_cmdlog | awk '{print $2}')
if [[ ${PID} -ne 0 ]]; then echo " =>logger_cmdlog($PID) kill"; $(kill -9 ${PID}); fi  

PID=$(ps -ef | grep $USER | grep -v "grep" | grep logger_resource | awk '{print $2}')
if [[ ${PID} -ne 0 ]]; then echo " =>logger_resource($PID) kill"; $(kill -9 ${PID}); fi

PID=$(ps -ef | grep $USER | grep -v "grep" | grep memtier | grep $port | awk '{print $2}')
if [[ ${PID} ]]; then echo " =>memtier($PID) kill"; $(kill ${PID}); waittime=10; fi

PID=$(ps -ef | grep $USER | grep -v "grep" | grep memcached | grep $port | awk '{print $2}')
if [[ ${PID} ]]; then echo " =>arcus($PID) kill";  $(kill ${PID}); waittime=10; fi

PID=$(ps -ef | grep $USER | grep -v "grep" | grep redis | grep $port | awk '{print $2}')
if [[ ${PID} -ne 0 ]]; then echo " =>redis($PID) kill"; $(kill ${PID}); waittime=10; fi

sleep $waittime
echo "Kill all test processes"

alive1=$(ps -ef | grep $USER | grep -v "grep" | grep -v "stop_test" | grep $port | awk '{print $2}')
alive2=$(ps -ef | grep $USER | grep -v "grep" | grep logger_ | awk '{print $2}')

if [[ $alive1 || $alive2 ]]; then
    echo "___ Delete error : Please delete in manual mode:___"
    echo $alive1
    echo $alive2 
fi
