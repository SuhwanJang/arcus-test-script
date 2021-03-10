#!/bin/sh
source readconfig.sh
logdir=""

# setting engine_config.conf
if [[ "$server_type" == "arcus" ]]; then
    if [[ "$server_mode" == "off" ]]; then
       $(sed -i '/use_persistence/c\use_persistence=false' ${engine_config})
    elif [[ "$server_mode" == "async" ]]; then
       $(sed -i '/async_logging/c\async_logging=true' ${engine_config})
       $(sed -i '/use_persistence/c\use_persistence=true' ${engine_config})
       $(sed -i "/data_path/c\data_path=$datapath" ${engine_config})
       $(sed -i "/logs_path/c\logs_path=$logpath" ${engine_config})
    else
       $(sed -i '/async_logging/c\async_logging=false' ${engine_config})
       $(sed -i '/use_persistence/c\use_persistence=true' ${engine_config})
       $(sed -i "/data_path/c\data_path=$datapath" ${engine_config})
       $(sed -i "/logs_path/c\logs_path=$logpath" ${engine_config})
    fi
fi

case $server_type in
arcus)
S_command="$HOME/arcus-memcached/memcached -d -v -r -R100 -p $port -b 8192 \
-m 11000 -t 6 -c 4096 -z 10.34.93.160:2170 \
-E $HOME/arcus-memcached/.libs/default_engine.so \
-X $HOME/arcus-memcached/.libs/ascii_scrub.so \
-X $HOME/arcus-memcached/.libs/syslog_logger.so \
-e config_file=$HOME/arcus-memcached/engines/default/default_engine.conf";;

redis) case $server_mode in
       off)   appendfsync="no"; appendonly="no";;
       sync)  appendonly="yes"; appendfsync="always";;
       async) appendonly="yes"; appendfsync="no";;   
       esac     
S_command="$HOME/redis-stable/src/redis-server --port $port --daemonize yes \
--maxclients 4096 --maxmemory 11gb --save "" --tcp-backlog 8192 --protected-mode no \
--appendonly ${appendonly} --appendfsync ${appendfsync} --auto-aof-rewrite-percentage 100 \
--auto-aof-rewrite-min-size 64mb --logfile $logdir/redis.log";;
esac

function run_server() {
    echo "Running Server.."
    logdir=$1
    nohup ${S_command} | ts >> testblog/arcus.log &
    sleep 5

    if [[ "$server_type" == "arcus" ]]; then
        PID=$(ps -ef | grep memcache | grep $port | awk '{print $2}')
    else
        PID=$(ps -ef | grep redis | grep $port | awk '{print $2}')
    fi

    if [[ $PID ]]; then
        echo -e "1) SERVER----------------------------------------------------
        Type : $server_type
        Mode : $server_mode
        Command :
        $S_command\n\n\n" >> "${2}"
    else
        echo "Failed to run server. check ${server_type} log."
        exit 0
    fi
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    run_server1
fi
