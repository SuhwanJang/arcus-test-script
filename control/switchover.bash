#!/bin/bash

function check_slavecpu() {
  durable=5
  sum=0
  requests=3
  for (( i=0; i<$requests; i++ ))
  do
    rusage=$(echo stats | nc $1 $2 | grep rusage_user | tr -d '\r' | cut -d' ' -f3 | cut -d'.' -f1)
    if [ -z "$rusage" ]; then
      echo "stats failed"
      return 1;
    else
      :
    fi
    
    sleep $durable;
    let "sum+=rusage"
   done
   let "sum/=requests"
   if [ $sum -gt 100000 ]; then
      echo "slave cpu usage is too high. host=$1:$2 rusage=$sum"
      return 1;
   fi
  return 0;
}

echo ">>>>>> $0 master_port slave_port start_time slave_hostname"

if [ -z "$1" ];
then
  master_port=11211
else
  master_port=$1
fi

if [ -z "$2" ];
then
  slave_port=11211
else
  slave_port=$2
fi

if [ -z "$3" ];
then
  start_time=10
else
  start_time=$3
fi

if [ -z "$4" ];
then
  run_interval=300
else
  run_interval=$4
fi

if [ -z "$5" ];
then
  echo "need to set slave_hostname"
  exit
else
  slave_hostname=$5
fi

#if [ -z "$5" ];
#then
#  run_count=1000000
#else
#  run_count=$5
#fi

echo ">>>>>> $0 $master_port $slave_port $start_time $run_interval $slave_hostname"

#can_test_failure="switchover_${master_port}.txt"
#if ! [ -f "$can_test_failure" ]; then
#  touch $can_test_failure
#fi

echo ">>>>>> sleep for $start_time before switchover"
sleep $start_time

file_time=0

COUNTER=1
#while [ $COUNTER -le $run_count ];
while true;
do
  echo ">>>>>> $0 running (COUNT=$COUNTER)"
    if  [ `expr $COUNTER % 2` == 1 ];
    then
      if check_slavecpu $slave_hostname $slave_port; then
        echo ">>>>>> execute switchover host=127.0.0.1:$master_port"
        echo "replication switchover" | nc localhost $master_port
      fi
    else
      if check_slavecpu 127.0.0.1 $master_port; then
        echo ">>>>>> execute switchover host=$slave_hostname:$slave_port"
        ssh $slave_hostname /bin/bash << EOF
        echo "replication switchover" | nc localhost $slave_port
EOF
      fi
    fi
  echo ">>>>>> sleep for $run_interval"
  sleep $run_interval
  echo ">>>>>> wakeup"
  
  let COUNTER=COUNTER+1
done
