#!/bin/sh

source readconfig.sh

case $server_type in
arcus) default_engine="$HOME/arcus-memcached/engines/default/default_engine.conf"
       case $server_mode in
       off)   $(sed -i 's/use_persistence=true/use_persistence=false/g' ${default_engine});;
       sync)  $(sed -i 's/async_logging=true/async_logging=false/g' ${default_engine})
              $(sed -i 's/use_persistence=false/use_persistence=true/g' ${default_engine});;
       async) $(sed -i 's/async_logging=false/async_logging=true/g' ${default_engine})
              $(sed -i 's/use_persistence=false/use_persistence=true/g' ${default_engine});;
       esac
S_command="$HOME/arcus-memcached/memcached -d -v -r -R100 -p $port -b 8192 \
-m 11000 -t 6 -c 4096 -z 10.34.93.160:2170 \
-E $HOME/arcus-memcached/.libs/default_engine.so \
-X $HOME/arcus-memcached/.libs/syslog_logger.so \
-X $HOME/arcus-memcached/.libs/ascii_scrub.so \
-e config_file=$HOME/arcus-memcached/engines/default/default_engine.conf";;

redis) case $server_mode in
       off)   appendfsync="no"; appendonly="no";;
       sync)  appendonly="yes"; appendfsync="always";;
       async) appendonly="yes"; appendfsync="no";;   
       esac     
S_command="$HOME/redis-stable/src/redis-server --port $port --daemonize yes \
--maxclients 4096 --maxmemory 11gb --save "" --tcp-backlog 8192 --protected-mode no \
--appendonly ${appendonly} --appendfsync ${appendfsync} --auto-aof-rewrite-percentage 100 \
--auto-aof-rewrite-min-size 64mb --logfile $1/redis.log";;
esac

${S_command} & 
sleep 1
C_PID=$(ps -ef | grep memcache | grep $port | awk '{print $2}')
S_PID=$(ps -ef | grep redis | grep $port | awk '{print $2}')
if [[ ${S_PID} || ${C_PID} ]]; then
echo -e "1) SERVER
-------------------------------------------------------------------------------
Type : $server_type
Mode : $server_mode
Command :
$S_command\n\n\n"
fi
