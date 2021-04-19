## 설정
- param.json : 서버 및 클라이언트 환경 및 옵션 설정
```
{
  "test_restart": "false", 
  "engine_config": "/home/persistence/arcus-memcached/engines/default/default_engine.conf",
  "logpath": "/home/persistence/arcus-memcached/ARCUS-DB",
  "datapath": "/data/persistence/ARCUS-DB",
  "client": "persistence@211.249.63.38 -p 11618",
  "server": "10.34.93.160",
  "port": 11300,
  "server_type": "arcus",
  "server_mode": "async",
  "threads": 8,
  "clients": 50,
  "keyminimum": 1,
  "keymaximum": 1000000,
  "run_count": 1,
  "data_size": 1,
  "client_mode": "1,2,3,5,6"
}

- test_restart : 테스트 케이스 완료 후 서버 재구동 여부
  - true 로 설정하면 set, get 연달아 테스트 시에 set 수행 후 서버 종료 후 데이터 다시 삽입한 이후 get 수행 
  - false 로 설정하면 set, get 연달아 테스트 시에 set 수행 후 서버 종료하지 않고 get 수행
- engine_config, logpath, datapath : arcus persistence 설정
- client : 클라이언트 구동할 장비 정보  
- server, port : 서버 구동할 장비 ip, port
- server_type : arcus or redis
- server_mode : persistence (off, async, sync)
- threads ~ data_size : memtier_benchmakr 옵션
- client_mode : 테스트 케이스(숫자별 수행할 테스트는 run_memtier.sh 파일 참고)
```

## 스크립트
- start_test.sh : 테스트 수행 (서버, 클라이언트, 스크립트 자동 구동/종료) 
- stop_test.sh : 테스트 종료 (서버, 클라이언트, 스크립트 자동 종료)
- run_server.sh : 서버 구동
- run_memtier.sh : 클라이언트 구동
- logger_chkpt.sh : checkpoint/rewrite 수행 상태 정보 기록
- logger_cmdlog.sh : cmdlog/appendonly 아이템 5% 증가별 로그 파일 크기 기록

### 기타
- show_logs.sh : 테스트별 허블 링크 및 memtier 로그 조회
- log_to_CSV.sh : memtier 로그를 CSV 파일로 변환.(redis 모니터링이 없어서 초당
  요청처리량을 보기 위함.)

## 사용법
### 테스트 수행
- param.json 수정 후 `bash start_test.sh` 수행.

### 테스트 중지
- `bash start_stop.sh` 수행.

## 폴더 구조

```bash
├── start_test.sh                        - TEST 실행 파일
├── stop_test.sh                         - TEST 중단 파일
│
├── run_server.sh                        - server 구동 파일
├── run_memtier.sh                       - client 구동 파일
│
│
├── logscripts/                          
│   ├── logger_chkpt.sh                  - checkpoint/rewrite 로그 관리
│   ├── logger_cmdlog.sh                 - cmdlog 로그 관리
│
│
└── log/                             - TEST 로그 저장 폴더
    └── 2021-02-18/                      - 실행 날짜별 폴더
        │
        ├── arcus-async_21:38:26/        - TEST SET 수행 단위 폴더 
        │   │
        │   ├── onlySet/                 - 개별 TEST 수행 정보 
        │   │   ├── memtier.log          - memtier_benchmakr 수행 결과 조회
        │   │   ├── result.log           - param.json 정보, 허블 링크, 구동 명령어 조회
        │   │   ├── cmdlog.log           - cmdlog/appendonly 파일 크기 조회
        │   │   └── chkpt.log            - checkpoint/rewrite 수행 상태 조회
        │   │
        │   └── onlyGetRandom/          
        │       ├── memtier.log
        │       └── result.log
        │
        │
        └── redis-async_21:58:26/         
            └── onlySet/                   
                ├── memtier.log
                ├── chkpt.log
                ├── cmdlog.log
                ├── result.log           
                ├── appendonly.aof       - AOF 파일
                └── redis.log            - redis 로그 파일
```
 
## TEST 로그 기록 

TEST 수행시 기록되는 log의 종류는 다음과 같습니다.
1) cmd_size.log 
: logger_cmdlog.sh 가 memtier의 item 삽입 진행률(%)에 맞춰 해당 진행률의 cmmand log file 크기를 기록합니다
```
20210219_101139 recording cmdlog start
0%: 46MB
5%: 190MB
10%: 578MB
15%: 421MB
20%: 814MB
25%: 1204MB
(중략)
100%: 1288MB
```

2) chkpt.log
: logger_chkpt.sh 가 checkpoint/rewrite의 발생 여부를 확인하며 checkpoint/rewrite 발생 시, 
해당 checkpoint/ rewrite의 정보 (시작시간/ 경과시간/ 스냅샷사이즈/ 실패여부)를 기록합니다.
```
20210219_101139 checkpoint stats
CHECKPOINT 1
StartTime     : 20210219101149
ElapsedTime   : 1
SnapshotSize  : 81MB
FailCount     : 0

CHECKPOINT 2
StartTime     : 20210219101210
ElapsedTime   : 4
SnapshotSize  : 251MB
FailCount     : 0

CHECKPOINT 3
StartTime     : 20210219101319
ElapsedTime   : 15
SnapshotSize  : 810MB
FailCount     : 0

CHECKPOINT 4
StartTime     : 20210219101649
ElapsedTime   : 44
SnapshotSize  : 2549MB
FailCount     : 0
```
3) result.log    
수행되었던 server와 client의 명령어와 TEST가 진행되었던 시간의 hubble 주소, param.json 을 기록합니다.   
```
Config File : param.json
{
  "test_restart": "false",
  "engine_config": "/home/persistence/arcus-memcached/engines/default/default_engine.conf",
  "logpath": "/home/persistence/arcus-memcached/ARCUS-DB",
  "datapath": "/data/persistence/ARCUS-DB",
  "client": "persistence@211.249.63.38 -p 11618",
  "server": "10.34.93.160",
  "port": 11300,
  "server_type": "arcus",
  "server_mode": "async",
  "threads": 8,
  "clients": 50,
  "keyminimum": 1,
  "keymaximum": 1000000,
  "run_count": 1,
  "data_size": 1,
  "client_mode": "1,2,3,5,6"
}
1) SERVER----------------------------------------------------
        Type : arcus
        Mode : async
        Command :
        /home/persistence/arcus-memcached/memcached -d -v -r -R100 -p 11300 -b 8192 -m 11000 -t 6 -c 4096 -z 10.34.93.160:2170 -E /home/persistence/arcus-memcached/.libs/default_engine.so -X /home/persistence/arcus-memcached/.libs/ascii_scrub.so -X /home/persistence/arcus-memcached/.libs/syslog_logger.so -e config_file=/home/persistence/arcus-memcached/engines/default/default_engine.conf

2) CLIENT ------------------------------------------------------------------------
Test : [1] onlySet
Command :
ssh -T persistence@211.249.63.38 -p 11618 /home/persistence/memtier_benchmark/memtier_benchmark -s 10.34.93.160 -p 11300 --protocol=memcache_text --threads=8 --clients=50 --data-size=1 --key-pattern=P:P --key-minimum=1 --key-maximum=1000000 --run-count=1 --ratio=1:0 --requests=2500 --print-percentiles=90,95,99 --show-config
Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=1618811710000&to=1618811720000&var-ensemble=jam2in-m001:2170&var-service_code=persistence&var-host=jam2in-m001&var-node=jam2in-m001:11300
```

4) memtier.log    
  : memtier와 관련된 로그 파일로 memtier config 정보와 진행률(%)에 따른 Ops, Latency를 확인할 수 있습니다.      
```
server = 10.34.93.160
port = 11300
unix socket = (null)
protocol = memcache_text
out_file = (null)
client_stats = (null)
run_count = 1
debug = 0
requests = 200000
clients = 50
threads = 8
test_time = 0
ratio = 1:0
pipeline = 1
data_size = 50
data_offset = 0
random_data = no
data_size_range = 0-0
data_size_list =
data_size_pattern = R
expiry_range = 0-0
data_import = (null)
data_verify = no
verify_only = no
generate_keys = no
key_prefix = memtier-
key_minimum = 1
key_maximum = 80000000
key_pattern = P:P
key_stddev = 0.000000
key_median = 0.000000
reconnect_interval = 0
multi_key_get = 0
authenticate =
select-db = 0
no-expiry = no
wait-ratio = 0:0
num-slaves = 0-0
wait-timeout = 0-0
json-out-file = (null)
8         Threads
50        Connections per thread
200000    Requests per client
.
.
.
[RUN #1 99%, 565 secs]  6 threads:    79570023 ops,  239885 (avg:  140830) ops/sec, 22.48MB/sec (avg: 13.20MB/sec),  1.66 (avg:  2.84) msec latency
[RUN #1 100%, 565 secs]  5 threads:    79719090 ops,  239885 (avg:  141005) ops/sec, 22.48MB/sec (avg: 13.22MB/sec),  1.66 (avg:  2.83) msec latency
[RUN #1 100%, 565 secs]  5 threads:    79858756 ops,  239885 (avg:  141184) ops/sec, 22.48MB/sec (avg: 13.23MB/sec),  1.66 (avg:  2.83) msec latency
[RUN #1 100%, 565 secs]  4 threads:    79964802 ops,  239885 (avg:  141329) ops/sec, 22.48MB/sec (avg: 13.25MB/sec),  1.66 (avg:  2.83) msec latency
[RUN #1 100%, 565 secs]  0 threads:    80000000 ops,  239885 (avg:  141382) ops/sec, 22.48MB/sec (avg: 13.25MB/sec),  1.66 (avg:  2.82) msec latency


ALL STATS
============================================================================================================================
Type         Ops/sec     Hits/sec   Misses/sec    Avg. Latency     p90 Latency     p95 Latency     p99 Latency       KB/sec
----------------------------------------------------------------------------------------------------------------------------
Sets        79293.12          ---          ---         5.08692         7.16700         7.99900        13.11900      6880.93
Gets            0.00         0.00         0.00             ---             ---             ---             ---         0.00
Waits           0.00          ---          ---             ---             ---             ---             ---          ---
Totals      79293.12         0.00         0.00         5.08692         7.16700         7.99900        13.11900      6880.93
```

## 기타 스크립트 사용 용도 
### show_logs.sh
```
$ ls ~/log/2021-04-19/arcus-async-14:55:04
onlyGetLongtail  onlyGetRandom  onlySet
```
특정 날짜와 시간에 수행한 테스트의 각 허블 주소와 memtier 결과를 조회 사용
수행 전 show_logs.sh 에 날짜와 시간, 서버 타입, 모드, 테스트 정보를 수정해야 함.

```
$ bash show_logs.sh
========== arcus-async-14:55:04-onlySet ==========
Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=1618811710000&to=1618811720000&var-ensemble=jam2in-m001:2170&var-service_code=persistence&var-host=jam2in-m001&var-node=jam2in-m001:11300
ALL STATS
============================================================================================================================
Type         Ops/sec     Hits/sec   Misses/sec    Avg. Latency     p90 Latency     p95
Latency     p99 Latency       KB/sec
----------------------------------------------------------------------------------------------------------------------------
Sets       118294.35          ---          ---         3.36064         5.85500
7.58300        13.31100      4261.47
Gets            0.00         0.00         0.00             ---             ---
---             ---         0.00
Waits           0.00          ---          ---             ---             ---
---             ---          ---
Totals     118294.35         0.00         0.00         3.36064         5.85500
7.58300        13.31100      4261.47


20210419_145514 checkpoint stats


20210419_145514 recording cmdlog start

========== arcus-async-14:55:04-onlyGetRandom ==========
Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=1618811770000&to=1618811779000&var-ensemble=jam2in-m001:2170&var-service_code=persistence&var-host=jam2in-m001&var-node=jam2in-m001:11300
ALL STATS
============================================================================================================================
Type         Ops/sec     Hits/sec   Misses/sec    Avg. Latency     p90 Latency     p95
Latency     p99 Latency       KB/sec
----------------------------------------------------------------------------------------------------------------------------
Sets            0.00          ---          ---             ---             ---
---             ---         0.00
Gets       150456.85    150456.85         0.00         2.63123         3.79100
5.05500        10.23900      7901.58
Waits           0.00          ---          ---             ---             ---
---             ---          ---
Totals     150456.85    150456.85         0.00         2.63123         3.79100
5.05500        10.23900      7901.58

========== arcus-async-14:55:04-onlyGetLongtail ==========
Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=1618811829000&to=1618811837000&var-ensemble=jam2in-m001:2170&var-service_code=persistence&var-host=jam2in-m001&var-node=jam2in-m001:11300
ALL STATS
============================================================================================================================
Type         Ops/sec     Hits/sec   Misses/sec    Avg. Latency     p90 Latency     p95
Latency     p99 Latency       KB/sec
----------------------------------------------------------------------------------------------------------------------------
Sets            0.00          ---          ---             ---             ---
---             ---         0.00
Gets       152203.27    152203.27         0.00         2.64213         3.29500
4.57500        11.39100      8024.19
Waits           0.00          ---          ---             ---             ---
---             ---          ---
Totals     152203.27    152203.27         0.00         2.64213         3.29500
4.57500        11.39100      8024.19
```

### log_to_CSV.sh
```
$ ls ~/log/2021-04-19/arcus-async-14:55:04
onlyGetLongtail  onlyGetRandom  onlySet
```
특정 날짜와 시간에 수행한 테스트의 memtier 로그를 읽어 CSV 파일로 변환.
수행 전 log_to_CSV.sh 에 날짜와 시간, 서버 타입, 모드, 테스트 정보를 수정해야 함.

```
$ bash log_to_CSV.sh
$ cat csv/arcus-async-14\:55\:04_onlySet.csv
time ops  latency
1   145399  3.19
2   124671  3.74
3   107190  3.70
4   108056  3.11
5   128399  3.16
6   126361  4.21
7   94772   4.39
8   91001   4.39
```

## 참고
1) key-median, key-stddev 설정        
 : Longtail 수행에 필요 옵션인 --key-median, --key-stddev 을 설정하지 않으면, default 값으로 key-median 은 key_range의 중앙값, key-stddev 은 key_range/6 으로 설정됩니다. 현재는 default 값으로 설정되도록 되어 있습니다.   

2) Redis의 경우 rewrite 수행 시 메모리 증가율이 높아지므로 THP=madvise 설정이 필요합니다.
