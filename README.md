# 실행 스크립트
Github 저장소에서 소스코드를 다운로드합니다.   
```bash
$ git clone -b persistence-test --single-branch https://github.com/jam2in/test-misc.git
```
주어진 옵션을 선택하여 server와 memtier의 설정값을 지정합니다.

```
$ ./start-test.sh # for test

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
테스트를 실행하기 전, 진행될 총 test의 개수가 보여지고 기존에 종료되지 못한 테스트와 관련된 프로세스들을 정리한 후 테스트를 구동합니다.
```
 TOTAL: 1 case(s) will be tested
 Before the test, Removing all alived processes .....
  =>redis kill
 (Removing processes done)
```
각각의 테스트케이스가 진행된 모습입니다.
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
 
============================================================
------------------------ TEST END --------------------------
============================================================
```

* 테스트 종료   
stop-test.sh를 실행한 뒤 관련된 port번호를 입력하여 종료합니다.
(```Enter port-number :```)   

 
 
 # 데이터 구조

데이터 흐름을 기준으로는 다음과 같습니다.

1. TEST 수행을 위해 start_test.sh를 실행 후 server와 client의 옵션 값을 설정합니다.
2. 서버 설정 값인 server_type과 server_mode와 port번호를 인자로 run_server.sh에게 넘겨주며 호출합니다.     
3-1. run_memtier.sh는 start_test.sh에서 받아온 인자를 이용하여 목적에 맞는 memtier 명령어를 생성합니다.
3-2. run_memtier.sh는 ssh 원격으로 생성된 memtier 명령어를 Client 장비에 전송하여 서버에 부하를 줍니다.  
4. memtier process가 생성되는 시점에 record_log 함수를 호출하여 로그 기록을 시작합니다.
4-1. log shell은 memtier process 종료 여부를 확인하며 로그 수행을 지속합니다.
5. memtier process 종료되면 모든 기록을 저장한 뒤 stop_test.sh를 호출하여 테스트 수행에 사용되었던
process를 모두 종료시킵니다

# 개선 사항

해당 스크립트는 TEST별로 하나의 서버를 구동하고 memtier 연산이 끝난 뒤 해당 서버 프로세스를 종료시켜 재사용을 방지한 구조입니다.
이는 비록 시간이 오래걸리나 정확한 system의 리소스를 확인하기 위해 설계된 구조입니다.

## 삽입 연산 선행

조회 연산과 혼합 연산의 테스트를 진행하기 위해서는 일정 수준의 데이터가 
server에 삽입되어 있어야 합니다. 때문에 조회와 혼합 연산을 진행하기 전에 삽입 연산을  
수행하여 server에 데이터를 충분히 적재됐는지 확인 후 테스트를 진행되도록 하였습니다.

## TEST 로그 기록 

TEST가 수행시 기록되는 log의 종류는 다음과 같습니다.
1) logger_cmdlog.sh   
: cmdlog server에 삽입된 item의 개수를 이용하여 memtier의 수행률(%)에 맞춰 
2) logger_chkpt.sh
: checkpoint/rewrite가 수행중임을 확인하여 
```'stats persistence'   # ARCUS ```
```'info persistence'    # Redis```
- checkpoint/rewrite의 로그를 기록하는 
3) logger_resource.sh    
: server와 client process의 CPU(%)와 server의 memory사용량(K)을 기록합니다.
추가적으로 연산에 수행되었던 server와 client의 구동 명령과 hubble주소를 기록합니다.

## 기타
1) G:G 가우시안 분포를 따르는 경우        
onlyGetLongtail/ GetSetLogtail과 같은 Longtail 연산은 수행시, 
평균과 표준편차 값을 default로 주기 위해 --key-median, --key-stddev 옵션을 설정하지 않습니다.      


## 테스팅

시간 관계상 redis의 경우는 rewrite가 일어날때 일정 수준 이상의 memory 공간이 있어야하므로




 
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
└── logfile/                             - TEST 로그 저장소
    └── 2021-02-18/                      - 실행 날짜 /
        ├── arcus-async_21:38:26/        - 서버 정보와 실행 시간 /
        │   └── onlySet/                 - 클라이언트 정보 /
        │       ├── memtier.log
        │       ├── chkpt.log
        │       ├── cmdlog.log
        │       └── result.log        
        │
        └── redis-async_21:58:26/        - 서버_실행 시간
            └── onlySet/                 - 부트스트랩이 사용하는 폰트들
                ├── memtier.log
                ├── chkpt.log
                ├── cmdlog.log
                ├── result.log
                ├── affendonly.log
                └── redis.log     
```
 
