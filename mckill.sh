## psarr=($(ps -ef | grep memcached | grep suhwan | grep -v "grep" |  awk '{print $2}'))
kill $(ps -ef | grep memcached | grep suhwan | grep -v "grep" |  awk '{print $2}')
sleep 3
