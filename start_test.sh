#!/bin/sh
source readconfig.sh

function server_run() {
    # remove data files
    if [[ $client_mode == "1" ]]; then
        echo "remove backup files."
        if [[ -d "$HOME/arcus-memcached/ARCUS-DB/" || -d "/data/$user/ARCUS-DB/" ]]; then
            $(rm -rf $HOME/arcus-memcached/ARCUS-DB/* /data/$user/ARCUS-DB/*)
        fi
        if [[ -f "appendonly.aof" ]]; then
            $(rm appendonly.aof)
        fi
    fi
    while :
    do
        if [[ $server_type == "arcus" ]]
        then
            PID=$(ps -ef | grep $user | grep memcached | grep $port | awk '{print $2}')
            if [[ $PID ]]; then echo " => Arcus started."; SERVER_PID=$PID; break; fi
        else
            PID=$(ps -ef | grep $user | grep redis | grep $port | awk '{print $2}')
            if [[ $PID ]]; then echo " => Redis started."; SERVER_PID=$PID; break; fi
        fi
        bash run_server.sh $logdir >> $FILENAME
        sleep 2
    done
}

#NO USE THIS
function client_insertion(){
    echo "=> Before the test, perform insertion operation first..."
    export START_TIME=$(date +%s)
    bash run_memtier.sh "$client_input/1" >> $FILENAME
    while :
    do
        sleep 10
        MPID=$(ssh -T persistence@211.249.63.38 -p $remote pgrep memtier) 
        if [[ "${#MPID}" == "0"* ]];then echo "  :Insertion opertation complete"; break; fi
    done
    export END_TIME=$(date +%s)
    echo -e "Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=${START_TIME}000&to=${END_TIME}000&var-ensemble=${hostname}:2170&var-service_code=${user}&var-host=${hostname}&var-node=${hostname}:$port\n\n" >> $FILENAME
}

function client_record_run(){
    export START_TIME=$(date +%s)
    bash run_memtier.sh $client_mode $logdir >> $FILENAME
    echo " => Memtier started."
    record_log 
    echo -e "\nTest Running.."
    while :
    do
        sleep 2
        MPID=$(ssh -T persistence@211.249.63.38 -p $remote pgrep memtier)
        if [[ "${#MPID}" == "0"* ]]; then break; fi
    done
    export END_TIME=$(date +%s)
    echo -e "Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=${START_TIME}000&to=${END_TIME}000&var-ensemble=${hostname}:2170&var-service_code=${user}&var-host=${hostname}&var-node=${hostname}:$port\n\n" >> $FILENAME

}

function record_log(){ 
    log_path="logscripts"
    bash ${log_path}/logger_resource.sh ${logdir} ${FILENAME} $SERVER_PID &
    echo " => logger_resource.sh started."
    # Do not record chkptlog in search mode
    if [[ "$server_mode" == *"sync"* || "$server_mode" == *"async"* ]]; then
        bash ${log_path}/logger_cmdlog.sh ${logdir} &
        echo " => logger_cmdlog.sh started."
        bash ${log_path}/logger_chkpt.sh ${logdir} &
        echo " => logger_chkpt.sh started."
    fi
}

if [[ $client_mode -eq 0 ]]; then client_mode="1, 2, 3, 4, 5, 6, 7, 8, 9"; fi
OLD_IFS=$IFS;IFS=,;client_modes=($client_mode);IFS=$OLD_IFS
client_array=()
for client_mode in "${client_modes[@]}"
do
    client_mode=$(echo $client_mode | sed 's/[^0-9]//g')
    client_array+=("$client_mode")
done

echo -e "\n${#client_array[*]} case(s) will be tested."
echo -e "Before the test, Kill test processes..."
bash stop_test.sh

# START TEST
# make log-directory
today="$(date '+%Y-%m-%d')"
now="$(date '+%H:%M:%S')"
testdir="$PWD/logfile/${today}/${server_type}-${server_mode}_${now}"
if [ ! -d $testdir ]; then mkdir -p $testdir; fi

for client_mode in "${client_array[@]}"
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

    echo -e "\n\n======================= START TEST =========================\n"
    printconfig
    echo -e "Test: $CLIENT_TEST"
    
    logdir="$testdir/$CLIENT_TEST"
    mkdir -p $logdir
    FILENAME=$logdir/result.log
    printconfig > $FILENAME

    echo "Run processes..."
    server_run
    if [[ "$client_mode" != "1" ]]; then echo "wait for recovery time."
        sleep 140
        curitem=$(echo "stats" | nc localhost 11300 | grep "curr_items" | tr -d "\r\n" | awk '{print $3}')
        maxitem=`expr $keymaximum - $keyminimum + 1`
        while :
        do
            if [ "$curitem" -lt "$maxitem" ]; then
                echo "curitem : $curitem, maxitem : $maxitem"
                sleep 10
            else
                break;
            fi
        done
    fi
    echo -e "2) CLIENT -------------------------------------------------------------------------------" >> $FILENAME
#    if [[ "$client_mode" != "1" ]]; then client_insertion; fi
    client_record_run  
    $(sed -i 's//\n/g' "${logdir}/memtier.log") # remove '^M' in memtier.log
#    if [[ -f "$logdir/appendonly.aof" ]]; then
#        rm $logdir/appendonly.aof
#    fi
    sleep 30

    echo -e "\nTest done, kill test processes"
    bash stop_test.sh
echo -e "======================== TEST END ==========================\n"

done

