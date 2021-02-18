#!bin/sh

if [[ $# -eq 0 ]] 
    then read -r -p "Enter port-number : " port
    else port=$1
fi

account=$(pwd | cut -d '/' -f 3)

while :
do
    sleep 2
    V_PID=$(ps -ef |grep $account |grep chkptlog | awk '{print $2}')
    if [[ ${V_PID} -ne 0 ]]; then echo " =>log manager kill"; $(kill -9 ${V_PID}); fi
    V_PID=$(ps -ef |grep $account |grep cpu_mean | awk '{print $2}')
    if [[ ${V_PID} -ne 0 ]]; then echo " =>log manager kill"; $(kill -9 ${V_PID}); fi  
    V_PID=$(ps -ef |grep $account |grep cmdlog | awk '{print $2}')
    if [[ ${V_PID} -ne 0 ]]; then echo " =>log manager kill"; $(kill -9 ${V_PID}); fi
    C_PID=$(ps -ef |grep $account |grep memtier| grep $port | awk '{print $2}')
    if [[ ${C_PID} ]]; then echo " =>memtier kill"; $(kill -9 ${C_PID}); fi
    S_PID=$(ps -ef |grep $account |grep memcache| grep $port | awk '{print $2}')
    if [[ ${S_PID} ]]; then echo " =>arcus kill";  $(kill -9 ${S_PID}); fi
    R_PID=$(ps -ef |grep $account |grep redis| grep $port | awk '{print $2}')
    if [[ ${R_PID} -ne 0 ]]; then echo " =>redis kill"; $(kill -9 ${R_PID}); fi


    PROCESS_LIST="$V_PID $C_PID $S_PID $R_PID"

    if [[ $PROCESS_LIST =~ ^[0~9]+$ ]]; then
        echo ">> Processes to remove : $PROCESS_LIST"
    else 
        echo " (Removing processes done)"
        break
    fi

    alive1=$(ps -ef| grep persistence | grep $port | cut -d ' ' -f 2)
    alive2=$(ps -ef| grep persistence | grep chkptlog | cut -d ' ' -f 2)

    if [[ $alive1 || $alive2 ]]; then
        echo "___ Delete error : Please delete in manual mode:___"
        echo $alive1
        echo $alive2 
    else
        break
    fi
done
