kill $(ps -ef | grep memcached | grep suhwan | grep -v "grep" |  awk '{print $2}')

sleep 3
 nohup bash run_master.sh 11440 > run_11440.log 2>&1
 sleep 1
 printf "set kv 0 0 3\r\nqwe\r\n" | nc localhost 11440
 printf "set asd 0 0 3\r\nqwe\r\n" | nc localhost 11440
 printf "set ccc 0 0 3\r\nqwe\r\n" | nc localhost 11440
 printf "set ddd 0 0 3\r\nqwe\r\n" | nc localhost 11440
 printf "set zi 0 0 3\r\nqwe\r\n" | nc localhost 11440
 echo "config mgaddr 127.0.0.1:31440" | nc localhost 11440


echo "run mg node "
 sleep 4
 nohup bash run_master.sh 11442 > run_11442.log 2>&1
 nohup bash run_master.sh 11443 > run_11443.log 2>&1
 echo "before migration"
 sleep 2
 echo "cluster join begin" | nc localhost 11442
echo "cluster join end" | nc localhost 11443
 sleep 5

 echo "get to localhost 11440"
 printf "get kv\r\n" | nc localhost 11440
 printf "get asd\r\n" | nc localhost 11440
 printf "get ccc\r\n" | nc localhost 11440
 printf "get ddd\r\n" | nc localhost 11440
 printf "get zi\r\n" | nc localhost 11440

 echo "get to localhost 11442"
 printf "get kv\r\n" | nc localhost 11442
 printf "get asd\r\n" | nc localhost 11442
 printf "get ccc\r\n" | nc localhost 11442
 printf "get ddd\r\n" | nc localhost 11442
 printf "get zi\r\n" | nc localhost 11442

 echo "get to localhost 11443"
 printf "get kv\r\n" | nc localhost 11443
 printf "get asd\r\n" | nc localhost 11443
 printf "get ccc\r\n" | nc localhost 11443
 printf "get ddd\r\n" | nc localhost 11443
 printf "get zi\r\n" | nc localhost 11443
