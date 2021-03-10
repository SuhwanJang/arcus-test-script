#!/bin/sh
source readconfig.sh

if [[ $server_type == "arcus" ]]
then protocol=memcache_text
else protocol=redis
fi

case $1 in
0|1) cli_mode="[1] onlySet"
C_command="ssh -T ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} \
--data-size=${data_size} --key-pattern=P:P --key-minimum=${keyminimum} --key-maximum=${keymaximum} --run-count=${run_count} \
--ratio=1:0 --requests=${requests} --print-percentiles=90,95,99 --show-config" ;;

2) cli_mode="[2] onlyGetRandom"
C_command="ssh -T ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} --key-pattern=R:R \
--distinct-client-seed --randomize --key-minimum=${keyminimum} --key-maximum=${keymaximum} --run-count=${run_count} \
--ratio=0:1 --requests=${requests} --print-percentiles=90,95,99 --show-config" ;;

3) cli_mode="[3] onlyGetLongtail"
C_command="ssh -t ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} --key-pattern=G:G \
--distinct-client-seed --randomize --key-minimum=${keyminimum} --key-maximum=${keymaximum} --run-count=${run_count} \
--ratio=0:1 --requests=${requests} \
--print-percentiles=90,95,99 --show-config" ;;

4) cli_mode="[4] GetSetRandom(1:9)"
C_command="ssh -t ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} --data-size=${data_size} \
--key-pattern=P:P --distinct-client-seed --randomize --key-minimum=${keyminimum} \
--key-maximum=${keymaximum} --ratio=1:9 --requests=${requests} --run-count=${run_count} \
--print-percentiles=90,95,99 --show-config" ;;

5) cli_mode="[4] GetSetRandom(3:7)"
C_command="ssh -t ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} --data-size=${data_size} \
--key-pattern=P:P --distinct-client-seed --randomize --key-minimum=${keyminimum} --run-count=${run_count} \
--key-maximum=${keymaximum} --ratio=3:7 --requests=${requests} \
--print-percentiles=90,95,99 --show-config" ;;

6) cli_mode="[4] GetSetRandom(5:5)"
C_command="ssh -t ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} --data-size=${data_size} \
--key-pattern=P:P --distinct-client-seed --randomize --key-minimum=${keyminimum} --run-count=${run_count} \
--key-maximum=${keymaximum} --ratio=5:5 --requests=${requests} \
--print-percentiles=90,95,99 --show-config" ;;

7) cli_mode="[5] GetSetLongtail(1:9)"
C_command="ssh -t ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} --data-size=${data_size} \
--key-pattern=G:G --distinct-client-seed --randomize --key-minimum=${keyminimum} \
--key-maximum=${keymaximum} \
--ratio=1:9 --requests=${requests} --print-percentiles=90,95,99 --show-config" ;;

8) cli_mode="[5] GetSetLongtail(3:7)"
C_command="ssh -t ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} --data-size=${data_size} \
--key-pattern=G:G --distinct-client-seed --randomize --key-minimum=${keyminimum} \
--key-maximum=${keymaximum} \
--ratio=3:7 --requests=${requests} --print-percentiles=90,95,99 --show-config" ;;

9) cli_mode="[5] GetSetLongtail(5:5)"
C_command="ssh -t ${client} \
$HOME/memtier_benchmark/memtier_benchmark -s ${server} -p ${port} \
--protocol=${protocol} --threads=${threads} --clients=${clients} --data-size=${data_size} \
--key-pattern=G:G --distinct-client-seed --randomize --key-minimum=${keyminimum} \
--key-maximum=${keymaximum} \
--ratio=5:5 --requests=${requests} --print-percentiles=90,95,99 --show-config" ;;
esac

echo -e "Test : $cli_mode\nCommand :\n$C_command"

if [[ $1 == "0" ]]
then ${C_command} &
else ${C_command} &>> $2/memtier.log &
fi
