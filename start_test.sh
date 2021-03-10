#!/bin/sh
source readconfig.sh
source stop_test.sh
source run_server.sh

function remove_backup_files() {
    # remove log, snapshot files
    echo "remove backup files."
    $(rm -rf $logpath/*)
    $(rm -rf $datapath/*)
    $(rm -rf appendonly.aof)
}

function client_insertion(){
    export START_TIME=$(date +%s)
    bash run_memtier.sh 0 >> $reslog
    while :
    do
        sleep 10
        MPID=$(ssh -T $client pgrep memtier) 
        if [[ "${#MPID}" == "0"* ]];then echo "  :Insertion opertation complete"; break; fi
    done
    export END_TIME=$(date +%s)
    echo -e "Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=${START_TIME}000&to=${END_TIME}000&var-ensemble=${hostname}:2170&var-service_code=${user}&var-host=${hostname}&var-node=${hostname}:$port\n\n" >> $reslog
    sleep 10
}

function run_client(){
    export START_TIME=$(date +%s)
    bash run_memtier.sh $client_mode $logdir >> $reslog
    echo " => Memtier started."
    record_log 
    echo -e "\nTest Running.."
    while :
    do
        sleep 2
        MPID=$(ssh -T $client pgrep memtier)
        if [[ "${#MPID}" == "0"* ]]; then break; fi
    done
    export END_TIME=$(date +%s)
    echo -e "Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=${START_TIME}000&to=${END_TIME}000&var-ensemble=${hostname}:2170&var-service_code=${user}&var-host=${hostname}&var-node=${hostname}:$port\n\n" >> $reslog
   $(sed -i 's//\n/g' "${logdir}/memtier.log") # remove '^M' in memtier.log
}

function record_log(){ 
    stop_scripts
    log_path="logscripts"
    # Do not record chkptlog in search mode
    if [[ "$server_mode" == "sync" || "$server_mode" == "async" ]]; then
        bash ${log_path}/logger_cmdlog.sh ${logdir} &
        echo " => logger_cmdlog.sh started."
        bash ${log_path}/logger_chkpt.sh ${logdir} &
        echo " => logger_chkpt.sh started."
    fi
#    bash ${log_path}/logger_resource.sh ${logdir} ${reslog} &
#    echo " => logger_resource.sh started."
}

function recovery_server() {
    echo "wait for recovery"
    while :
    do
        sleep 20
        if [[ "$server_type" == "redis" ]]; then
            loading=$(echo "info persistence" | nc localhost ${port} | grep -w "loading" | cut -d ":" -f 2 | tr -d "\r\n")
        else
            loading=$(nc -w 1 -v localhost 11300 </dev/null; echo $?)
            echo $loading
        fi
        if [[ "$loading" == "1"* ]]; then
            continue;
        else
            break;
        fi
    done
    sleep 10
}

if [[ $client_mode -eq 0 ]]; then client_mode="1, 2, 3, 4, 5, 6, 7, 8, 9"; fi
OLD_IFS=$IFS;IFS=,;client_modes=($client_mode);IFS=$OLD_IFS
client_array=()
for client_mode in "${client_modes[@]}"
do
    client_mode=$(echo $client_mode | sed 's/[^0-9]//g')
    client_array+=("$client_mode")
done

echo -e "Before the test, Kill test processes..."
stop_processes

echo -e "\n${#client_array[*]} case(s) will be tested."

today="$(date '+%Y-%m-%d')"
now="$(date '+%H:%M:%S')"
testdir="$testlogdir/${today}/${server_type}-${server_mode}-${now}"
if [ ! -d $testdir ]; then mkdir -p $testdir; fi

for client_mode in "${client_array[@]}"
do
    case $client_mode in
        1) client_test="onlySet";;
        2) client_test="onlyGetRandom";;
        3) client_test="onlyGetLongtail";;
        4) client_test="GetSetRandom(1:9)";;
        5) client_test="GetSetRandom(3:7)";;
        6) client_test="GetSetRandom(5:5)";;
        7) client_test="GetSetLongtail(1:9)";;
        8) client_test="GetSetLongtail(3:7)";;
        9) client_test="GetSetLongtail(5:5)";;
    esac

    echo -e "\n\n======================= START TEST =========================\n"
    printconfig
    echo -e "Test: $client_test"

    logdir="$testdir/$client_test"
    mkdir -p $logdir
    reslog=$logdir/result.log
    touch $reslog
    printconfig > $reslog
    
    if [[ "$client_mode" == "1" ]]; then
        remove_backup_files
        run_server $logdir $reslog
        echo -e "2) CLIENT ------------------------------------------------------------------------" >> $reslog
    else 
        if [[ "$test_restart" == "true" ]]; then
            echo -e "\nrestart server and recovery if persistence using"
            stop_processes
            sleep 5

            run_server $logdir $reslog

            if [[ "$server_mode" != "off" ]]; then
# fsync, flush wait
                recovery_server
            fi
        fi
    fi

    if [[ "$client_mode" != "1" && "$test_restart" == "true" ]]; then
        echo "=> Before the test, perform insertion operation first..."
        client_insertion
    fi

    echo -e "2) CLIENT ------------------------------------------------------------------------" >> $reslog
    run_client
    sleep 50
    echo -e "======================== END TEST ==========================\n"
done
echo -e "\nTest done, kill test processes"
stop_processes
