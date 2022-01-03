kill $(ps -ef | grep memcached | grep suhwan | grep -v "grep" |  awk '{print $2}')
sleep 4
 nohup bash run_master.sh 11440 > run_11440.log 2>&1
 sleep 1
 nohup bash run_master.sh 11441 > run_11441.log 2>&1
 sleep 1
 nohup bash run_master.sh 11500 > run_11500.log 2>&1
 sleep 1
 nohup bash run_master.sh 11501 > run_11501.log 2>&1
 sleep 1
echo "config mgaddr 127.0.0.1:31440" | nc localhost 11440
echo "config mgaddr 127.0.0.1:31441" | nc localhost 11441
echo "config mgaddr 127.0.0.1:31500" | nc localhost 11500
echo "config mgaddr 127.0.0.1:31501" | nc localhost 11501

echo "before migration 3"
sleep 3
echo "before migration 2"
sleep 1
echo "before migration 1"
sleep 1
echo "cluster leave begin" | nc localhost 11440
echo "cluster leave end" | nc localhost 11441
sleep 10

echo $(ps -ef | grep memcached | grep suhwan | grep -v "grep")
