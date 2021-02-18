#!/bin/sh

# SERVER SETTING
function server_setting(){ 
    read -r -p "Server type: 1) Arcus  2) Redis : " server_type
    read -r -p "Server mode: 1) Off  2) Async  3) Sync :  " server_mode
    server_type_list=("" "arcus" "redis")
    server_mode_list=("" "off" "async" "sync")
    if [[ server_type -le 2 ]]; then server_type=${server_type_list[$server_type]}; fi
    if [[ server_mode -le 3 ]]; then server_mode=${server_mode_list[$server_mode]}; fi
}

# CLIENT SETTING 
function memtier_setting(){ 
    if [[ $server_type == *"arcus"* ]]
        then protocol=memcache_text
        else protocol=redis
    fi
    read -r -p "Threads: " threads
    read -r -p "Clients: " clients  
    read -r -p "Key-maximum: 0) input  1) 100 Mil  2) 80 Mil  3) 50 Mil  4) 10 Mil :  " keymaximum
    keymaximum_list=("" "100000000" "80000000" "50000000" "10000000")
    if [[ keymaximum -eq 0 ]]; then read -r -p "> put any number you want: " keymaximum; fi
    if [[ keymaximum -ge 1 && keymaximum -le 4 ]]; then keymaximum=${keymaximum_list[$keymaximum]}; fi
    read -r -p "Key-minimum: 0) input  1) 1 :  " keyminimum
    keyminimum_list=("" "1")
    if [[ keyminimum -eq 0 ]]; then read -r -p "> put any number you want: " keyminimum; fi
    if [[ keyminimum -ge 1 && keyminimum -le 1 ]]; then keyminimum=${keyminimum_list[$keyminimum]}; fi
    read -r -p "Data size(Bytes): 0) input  1) 50  2) 750 : " data_size
    data_size_list=("" "50" "750")
    if [[ data_size -eq 0 ]]; then read -r -p "> put any number you want: " data_size; fi
    if [[ data_size -ge 1 && data_size -le 2 ]]; then data_size=${data_size_list[$data_size]}; fi    

    read -r -p "Test case (multiple select: 1, 2, 3) 
     0) All
     1) onlySet
     2) onlyGetRandom
     3) onlyGetLongtail
     4) GetSetRandom (1:9)
     5) GetSetRandom (3:7)
     6) GetSetRandom (5:5)
     7) GetSetLongtail (1:9)
     8) GetSetLongtail (3:7)
     9) GetSetLongtail (5:5)
     >> " client_mode

    if [[ $client_mode -eq 0 ]]; then client_mode="1, 2, 3, 4, 5, 6, 7, 8, 9"; fi
    OLD_IFS=$IFS;IFS=,;client_modes=($client_mode);IFS=$OLD_IFS

    client_array=()
    for client_mode in "${client_modes[@]}"
    do
        client_mode=$(echo $client_mode | sed 's/[^0-9]//g') 
        client_array+=("$client_mode")
    done
}

function server_run(){
    # AOF file 제거
    if [[ -d "/home/$account/ARCUS-DB/" || -d "/data/$account/ARCUS-DB/" ]]; then
        $(rm -rf /home/$account/ARCUS-DB/ /data/$account/ARCUS-DB/)
    fi
    $(mkdir /home/$account/ARCUS-DB /data/$account/ARCUS-DB)
    if [[ -f "$path/appendonly.aof" ]]; then
        $(rm $path/appendonly.aof)
    fi
    echo "=> Wait for the server turn on ..."
    while : 
    do  
        sleep 4
        C_PID=$(ps -ef | grep $account | grep memcached |grep $port |awk '{print $2}')
        S_PID=$(ps -ef | grep $account | grep redis | grep $port |awk '{print $2}')
        if [[ $C_PID ]]; then echo "  :Arcus SERVER ON"; SERVER_PID=$C_PID; break; fi
        if [[ $S_PID ]]; then echo "  :Redis SERVER ON"; SERVER_PID=$S_PID; break; fi
        bash $path/run_server.sh $1 $port >> $FILENAME
    done
}
# CLIENT operation
function client_insertion(){
    echo "=> Before the test, perform Insertion operation first..."
    export START_TIME=$(date +%s)
    bash $path/run_memtier.sh "$client_input/1" $port >> $FILENAME
    while :
    do
        sleep 10
        MPID=$(ssh -T persistence@211.249.63.38 -p $remote pgrep memtier) 
        if [[ "${#MPID}" == "0"* ]];then echo "  :Insertion opertation complete"; break; fi
    done
    export END_TIME=$(date +%s)
    echo -e "Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=${START_TIME}000&to=${END_TIME}000&var-ensemble=${hostname}:2170&var-service_code=${account}&var-host=${hostname}&var-node=${hostname}:$port\n\n" >> $FILENAME
}

function client_record_run(){
    export START_TIME=$(date +%s)
    bash $path/run_memtier.sh "$client_input/$client_mode" $port >> $FILENAME
    echo "  :CLIENT ON"
    record_log 
    while :
    do
        sleep 2
        MPID=$(ssh -T persistence@211.249.63.38 -p $remote pgrep memtier)
        if [[ "${#MPID}" == "0"* ]]; then break; fi
    done
    export END_TIME=$(date +%s)
    echo -e "Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=${START_TIME}000&to=${END_TIME}000&var-ensemble=${hostname}:2170&var-service_code=${account}&var-host=${hostname}&var-node=${hostname}:$port\n\n" >> $FILENAME

}

# Record log
function record_log(){ 
    log_path="$path/logscripts"
    bash ${log_path}/logger_resource.sh ${record_path} ${FILENAME} $SERVER_PID &
    # Do not record chkptlog in search mode
    if [[ "$server_mode" == *"sync"* || "$server_mode" == *"async"* ]]; then
        bash ${log_path}/logger_cmdlog.sh ${record_path} ${keymaximum} &
        bash ${log_path}/logger_chkpt.sh ${record_path} &
    fi
}

# define server IP(현재 사용중 IP를 확인해서)
server=$(hostname -I)
server="$(echo -e "${server}" | tr -d '[:space:]')"
case ${server} in
10.34.93.160) remote="11618";; # m002
10.34.91.143) remote="11617";; # m001
esac

# check account
account=$(pwd | cut -d '/' -f 3)
path=$(pwd)
hostname=$(hostname)
port=11300

# setting server & client
server_setting
memtier_setting

echo -e "\n TOTAL: ${#client_array[*]} case(s) will be tested"
echo -e " Before the test, Removing all alived processes ..... "
bash $path/stop-test.sh $port; sleep 6

# START TEST
# make log-directory
today="$(date '+%Y-%m-%d')"
now="$(date '+%H:%M:%S')"
test_path="$path/logfile/${today}/${server_type}-${server_mode}_${now}"
if [ ! -d $test_path ]; then mkdir -p $test_path; fi
cd $test_path

count=0
for client_mode in "${client_array[@]}"  # client: 5 types of memtier-benchmark
do
    case $client_mode in
        1) CLIENT_TEST="onlySet";;
        2) CLIENT_TEST="onlyGetRandom";;
        3) CLIENT_TEST="onlyGetLongtail";;
        4) CLIENT_TEST="GetSetRandom(1:9)";;
        5) CLIENT_TEST="GetSetRandom(3:7)";;
        6) CLIENT_TEST="GetSetRandom(5:5)";;
        7) CLIENT_TEST="GetSetLongtail(1:9)";;
        8) CLIENT_TEST="GetSetLongtail(3:7)";;
        9) CLIENT_TEST="GetSetLongtail(5:5)";;
    esac
    count=$(($count+1)) 
    echo -e "\n\n
============================================================
----------------------- START TEST -------------------------
============================================================\n"
    echo -e "Test $count): \n $CLIENT_TEST / [${server_type}-${server_mode}]"
    echo -e "threads=$threads, clients=$clients, keymaximum=$keymaximum, data_size=${data_size}"
    
    record_path=$test_path/$CLIENT_TEST
    mkdir -p $record_path
    cd $record_path
    FILENAME=result.log

    # server on
    server_run "${server_type}-${server_mode}" $port
    # 삽입 이외의 나머지 연산은  arcus/redis 삽입연산 후 원하는 연산 수행
    client_input="${threads}/${clients}/${keymaximum}/${keyminimum}/${data_size}/${protocol}"
    echo -e "2) CLIENT
-------------------------------------------------------------------------------" >> $FILENAME
    if [[ "$client_mode" != "1" ]]; then client_insertion; fi
echo -e "\n\n
============================================================
------------------------ CLIENT TEST------------------------
============================================================\n\n" >> ${record_path}/memtier.log
    client_record_run  
    $(sed -i 's//\n/g' "${record_path}/memtier.log") # remove '^M' in memtier.log
    sleep 10
    # If memtier over -> Close all process
    echo -e "\n Test done, close all related processes"
    bash $path/stop-test.sh $port

done
echo -e "\n\n
============================================================
------------------------ TEST END --------------------------
============================================================\n"
