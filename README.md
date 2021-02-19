# 실행 스크립트
Github 저장소에서 소스코드를 다운로드합니다.   
```
$ git clone -b persistence-test --single-branch https://github.com/jam2in/test-misc.git
```
본격적으로 테스트를 진행하기 위해 ```start_test.sh``` 를 구동합니다.   
server, client와 관련된 속성들이 순차적으로 주어집니다. 옵션을 선택하여 값을 설정합니다.
```
$ ./start_test.sh  
Server type: 1) Arcus  2) Redis : 
Server mode: 1) Off  2) Async  3) Sync :  
Threads: 
Clients: 
Key-maximum: 0) input  1) 100 Mil  2) 80 Mil  3) 50 Mil  4) 10 Mil :  
Key-minimum: 0) input  1) 1 :  
Data size(Bytes): 0) input  1) 50  2) 750 : 
Test case (multiple select: 1, 2, 3)
     0) All
     1) onlySet
     2) onlyGetRandom
     3) onlyGetLongtail
     4) GetSetRandom (1:9)
     5) GetSetRandom (3:7)
     6) GetSetRandom (5:5)
     7) GetSetLongtail (1:9)
     8) GetSetLongtail (3:7)
     9) GetSetLongtail (5:5)
     >> 
```
옵션 선택이 끝나면, 진행될 TEST의 총 개수가 보여집니다.   
혹여 종료되지 못한 이전 TEST의 프로세스가 있다면 이를 정리한 후 테스트를 구동합니다.   
```
 TOTAL: 9 case(s) will be tested
 Before the test, Removing all alived processes .....
  =>redis(75933) kill
 (Removing processes done)
```

하나의 TEST가 진행된 모습입니다.   
TEST와 관련된 간단한 info가 제시되며, 진행중인 상황을 알 수 있도록 로그를 보여줍니다.   
각 TEST가 끝나면 관련된 프로세스들을 모두 종료시키도록 하였습니다.   
```
============================================================
----------------------- START TEST -------------------------
============================================================
Test 1):
 onlyGetRandom / [redis-async]
threads=8, clients=50, keymaximum=10000000, data_size=750
=> Wait for the server turn on ...
  :Redis SERVER ON
=> Before the test, perform Insertion operation first...
  :Insertion opertation complete
  :CLIENT ON
=> Resource-recording start
  :Recording done

 Test done, close all related processes
 =>redis kill
 (Removing processes done)
 
=========================TEST END===========================
```

* TEST 도중 중단이 필요한 경우, ```stop-test.sh``` 를 실행하여 관련 프로세스들을 종료시킵니다.
```
$ ./stop_test.sh
Enter port-number :   # related port number
```   

 
 
 # 데이터 구조

데이터 흐름의 기준은 다음과 같습니다.

1.  TEST 수행을 위해 start_test.sh를 실행 후 server와 client의 옵션 값을 설정합니다.   
2.  서버 설정 값인 server_type과 server_mode, port번호를 run_server.sh에게 넘겨줍니다.     
2-1.  run_server.sh는 전달 받은 인자를 이용해 server의 타입을 확인하고 해당 서버의 conf 파라미터를 조정하여 구동합니다.   
3.  서버가 구동된 것을 확인 후, start_test.sh는 클라이언트 설정값을 run_memtier.sh에게 넘겨줍니다.   
3-1.  run_memtier.sh는 start_test.sh에서 받아온 인자를 이용하여 목적에 맞는 memtier 명령어를 생성합니다.   
3-2.  run_memtier.sh는 ssh 원격으로 생성된 memtier 명령어를 Client 장비에 전송하여 서버에 부하를 주도록 합니다.     
4.  start_test.sh는 memtier process가 생성된 것을 확인하면 record_log 함수를 호출하여 로그 기록을 시작합니다.   
4-1.  로그 관련 shell(logscripts)들은 memtier process의 존재 여부를 확인하며 로그 수행을 지속합니다.   
5.  start_test.sh는 memtier process가 종료되면 모든 로그를 저장한 뒤, stop_test.sh를 호출하여 테스트 수행에 사용되었던 process들을 종료시킵니다.   

 # 폴더 구조

```bash
├── README.md                            - 리드미 파일
│
├── start_test.sh                        - TEST 실행 파일
├── stop_test.sh                         - TEST 중단 파일
│
├── run_server.sh                        - server 설정 및 구동 파일
├── run_memtier.sh                       - client 설정 및 구동 파일
│
│
├── logscripts/                          - TEST 로그 기록 폴더
│   ├── logger_chkpt.sh                  - checkpoint/rewrite 로그 관리
│   ├── logger_cmdlog.sh                 - cmdlog 로그 관리
│   └── logger_resource.sh               - system resource 로그 관리
│
│
└── logfile/                             - TEST 로그 저장 폴더
    └── 2021-02-18/                      - 실행 날짜별 폴더
        │
        │
        ├── arcus-async_21:38:26/        - TEST SET 수행 단위 폴더 
        │   │
        │   ├── onlySet/                 - 개별 TEST 수행 정보 
        │   │   ├── memtier.log          - memtier 로그 파일
        │   │   ├── result.log           - system resource 로그 파일
        │   │   ├── cmdlog.log           - cmdlog-file size 로그 파일
        │   │   └── chkpt.log            - checkpoint/rewrite 로그 파일
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
 
 * TEST 로그 저장소의 디렉토리 구조는 다음과 같습니다.   
   수행 날짜 (DATE)     
   └── 진행된 TEST SET (테스트 단위는 한가지 종류의 서버를 대상으로 함 "디렉토리 명: Server_type-Server_mode")     
        └── 진행된 각각의 TEST ("디렉토리 명: 해당 서버에 대해 구동한 client의 정보")
 
 
## TEST 로그 기록 

TEST 수행시 기록되는 log의 종류는 다음과 같습니다.
1) logger_cmdlog.sh   
: memtier의 item 삽입 진행률(%)에 맞춰 해당 진행률의 평균 cmmand log file 크기를 기록합니다
```
20210219_101139 recording cmdlog start
AVG: (0%): 46MB
AVG: (5%): 190MB
AVG: (10%): 578MB
AVG: (15%): 421MB
AVG: (20%): 814MB
AVG: (25%): 1204MB
AVG: (30%): 1606MB
AVG: (35%): 270MB
AVG: (40%): 662MB
AVG: (45%): 1059MB
AVG: (50%): 1454MB
AVG: (55%): 1846MB
AVG: (60%): 2245MB
AVG: (65%): 2649MB
AVG: (70%): 3048MB
AVG: (75%): 3435MB
AVG: (80%): 3846MB
AVG: (85%): 140MB
AVG: (90%): 529MB
AVG: (95%): 925MB
AVG: (100%): 1288MB
```

2) logger_chkpt.sh
: checkpoint/rewrite의 발생 여부를 확인하며 checkpoint/rewrite 발생 시,   
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
3) logger_resource.sh    
: server와 client process의 CPU(%)와 server의 memory 사용량(K)을 기록합니다.   
추가적으로 연산에서 수행되었던 server와 client의 명령어와 TEST가 진행되었던 시간의 hubble 주소를 기록합니다.   
```
1) SERVER
-------------------------------------------------------------------------------
Type : arcus
Mode : sync
Command :
/home/persistence/arcus-memcached/memcached -d -v -r -R100 -p 11300 -b 8192 -m 13000 -t 6 -c 4096 -z 10.34.93.160:2170 -E /home/persistence/arcus-memcached/.libs/default_engine.so -X /home/persistence/arcus-memcached/.libs/syslog_logger.so -X /home/persistence/arcus-memcached/.libs/ascii_scrub.so -e config_file=/home/persistence/arcus-memcached/engines/default/default_engine.conf


2) CLIENT
-------------------------------------------------------------------------------
Test : [1] onlySet
Command :
ssh -T persistence@211.249.63.38 -p 11618 /home/persistence/memtier_benchmark/memtier_benchmark -s 10.34.93.160 -p 11300 --protocol=memcache_text --threads=8 --clients=50 --data-size=50 --key-pattern=P:P --key-minimum=1 --key-maximum=80000000 --ratio=1:0 --requests=200000 --print-percentiles=90,95,99 --show-config
Hubble Url :
http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?orgId=1&from=1613697099000&to=1613698138000&var-ensemble=jam2in-m001:2170&var-service_code=persistence&var-host=jam2in-m001&var-node=jam2in-m001:11300


3) SYSTEM RESOURCE
-------------------------------------------------------------------------------
>> Average server CPU(%) : 228%
>> Average client CPU(%) : 126%
>> TEST_TIME : 2021/02/19 10:11:39 ~ 2021/02/19/ 10:29:04
>> Used MEM(K) : 12147804(K)
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



## 삽입 연산 선행

조회 연산과 혼합 연산의 테스트를 진행하기 위해서는 일정 수준의 데이터가     
server에 삽입되어 있어야 합니다. 이를 위해 조회와 혼합 연산의 경우는 삽입 연산을     
우선적으로 수행하여 server에 데이터를 충분히 적재했는지 확인 후 테스트를 진행합니다.

## 기타
1) key-median, key-stddev 설정        
 : Longtail 수행에 필요 옵션인 --key-median, --key-stddev 을 설정하지 않으면, default 값으로 key-median 은 key_range의 중앙값, key-stddev 은 key_range/6 으로 설정됩니다. 현재는 default 값으로 설정되도록 되어 있습니다.   

2) 구동중인 테스트의 실시간 ops/latency 진행률은 memtier.log를 보시면 됩니다. (``` $ tail -f [path]/memtier.log ```)

3) 다음 테스트의 서버를 구동하기 전, 기존의 생성된 백업파일(AOF/snapshot file/commandlog file)은 자동으로 삭제됩니다.   
   따라서 데이터를 복구하는 과정이 필요하다면 백업파일을 따로 보관할 필요가 있습니다.

4) Redis의 경우 rewrite가 일어나는 과정에서 일정수준 이상의 메모리가 확보되어야 하는 것이 확인되었습니다.   
   이 경우 rewrite가 일어나도 메모리 부족 현상이 발생하지 않도록 적절한 계산이 요구됩니다. 
   [참조 (redis sync 3:7)](http://1.255.51.181:8088/d/RaYRxEgmz/01-system-resources?from=1612852818101&to=1612857251191&var-ensemble=jam2in-m001:2170&var-service_code=persistence&var-node=jam2in-m001:11300&var-node_host=jam2in-m001&var-node_port=11300&var-host=jam2in-m001&orgId=1)
   


## 개선 사항
해당 스크립트는 TEST별로 하나의 서버를 구동하고 memtier 연산이 끝난 뒤 해당 서버 프로세스를 종료시켜 server의 재사용을 방지한 구조입니다.
시간 소요가 많이 요구되는 삽입 연산의 경우 백업 파일을 보관하고 다시 load하는 과정으로 변경할 필요가 있습니다.
```
# start_test.sh 
function client_insertion()
```
 ## 테스팅
 


