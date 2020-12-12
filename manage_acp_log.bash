logfile="nohup.out"
client_logdir="/data/long_running_test_logs"
java_enterprise=$client_logdir/enterprise/java
c_enterprise=$client_logdir/enterprise/c
java_community=$client_logdir/community/java
c_community=$client_logdir/community/c
host1="jam2in-m001"
host2="jam2in-s001"
host3="jam2in-s002"
hosts=($host1 $host2 $host3)
eports=(11700 11701 11800 11801)
cports=(11500 11501)
abnormal_connection_ent=1
abnormal_connection_com=1
res=0

function check_connection() {
  limit=200
  connection=$(echo stats | nc $1 $2 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
  if [ "0$connection" -ge "$limit" ]; then
    echo "abnormal connection=$connection"
    res=0
    return;
  fi
  res=1
}

function check_truncate() {
  running_c=`ps -ef | grep -v "grep" | grep "acp-c/config-standard.txt" | wc -l` 
  running_java=`ps -ef | grep -v "grep" | grep "acp-java/config-arcus-integration" | wc -l` 
  if [[ $1 = 1 && $running_c -ge 2 && $running_java -ge 2 ]]; then
    res=0
    return;
  fi
  echo "don't truncate log file. need to check error. $1, alive_c=$running_c, alive_java=$running_java"
  res=1
}

function truncate_file() {
  cd $1
  logdir="test_logs"
  truncated_log="truncated.log"
  if [ ! -d "$logdir" ]; then
    mkdir $logdir
    touch $logdir/$truncated_log
  fi

  if [ ! -f "$logdir/$truncated_log" ]; then
    touch $logdir/$truncated_log
  fi

#10G
  tlimit=10000000000 
  filesize=`wc -c $logdir/$truncated_log | awk '{print $1}'`
  if [ $? -eq 0 ]; then
    if [ $filesize -ge $tlimit ]; then
      rm -rf $logdir/$truncated_log
      touch $logdir/$truncated_log
    fi
  fi

#1G
  limit=1000000000 
  filesize=`wc -c $logfile | awk '{print $1}'`
  if [ $filesize -ge $limit ]; then
    c_line="disabled=0 no_server=0 client=0 other=0|SCREAM"
    java_line="latency|per-client requests"
    common="cumulative|ELEMENT_EXISTS|EXISTS|TYPE_MISMATCH"
    truncate_line="$common|$c_line|$java_line"
    grep -vwE "($truncate_line)" $logfile >> $logdir/$truncated_log
    cat /dev/null > $logfile
    echo "truncated $1/$logfile. filesize=$filesize, filesize_limit=$limit"
    sleep 10
  fi
}

while true;
do
  for port in "${eports[@]}"; do
    for host in "${hosts[@]}"; do
      check_connection $host $port
      abnormal_connection_ent=$res
    done
  done
  check_truncate $abnormal_connection_ent
  if [ $res ]; then
    truncate_file $java_enterprise
    truncate_file $c_enterprise
  fi
  for port in "${cports[@]}"; do
    for host in "${hosts[@]}"; do
      check_connection $host $port
      abnormal_connection_com=$res
    done
  done
  check_truncate $abnormal_connection_com
  if [ $res ]; then
    truncate_file $java_community
    truncate_file $c_community
  fi
#3H
    sleep 3600
done
