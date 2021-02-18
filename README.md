# test-misc
## RUN
* 다운로드   

Github 저장소에서 소스코드를 다운로드합니다.   
```$ git clone -b persistence-test --single-branch https://github.com/jam2in/test-misc.git```
    
   
* 실행 방법   

해당 디렉토리에서 start-test.sh를 실행시킨 뒤 주어진 옵션을 선택하여 server와 memtier의 설정값을 정합니다.
```
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
테스트를 종료하고 난 뒤 stop-test.sh를 실행하여 port번호를 입력한뒤 관련된 프로세스를 모드 종료해줍니다.

 G:G 가우시안 분포와 관련해 --key-median, --key-stddev 옵션을 주지 않으면 평균과 표준편차 값이 default로 주어집니다.   
 
 
 
