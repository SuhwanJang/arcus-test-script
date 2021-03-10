DATE="2021-04-19"
TIME="14:55:04"
TYPES=( "arcus" "redis" )
MODES=( "off" "async" "sync" )
CASES=( "onlySet" "onlyGetRandom" "onlyGetLongtail" )

function getResult() {
    array=$(find ./log/$DATE/* -name $1)
    for x in ${array[@]}; do
        for case in ${CASES[@]}; do
            echo -e "\n========== $1-$case =========="
#Hubble Link
            cat $x/$case/result.log | grep -A 1 "Hubble*"
#Memtier result
            cat $x/$case/memtier.log | grep -A 8 "ALL"
            if [[ "$1" == *"async"* || "$1" == *"sync"* ]]; then 
               cat $x/$case/chkpt.log 
               cat $x/$case/cmd_size.log 
               echo ""
            fi
        done
    done
}

function getHubble() {
    array=$(find ./* -name $1*)
    for x in ${array[@]}; do
        echo ======= $x
        cat $x/result.log | grep -A 1 "Hubble*"
    done
}

function getMemtierResult() {
    array=$(find ./* -name $1*)
    for x in ${array[@]}; do
        echo ======= $x
        cat $x/memtier.log | grep -A 8 "ALL"
    done
}

for t in ${TYPES[@]}; do
    for m in ${MODES[@]}; do
        getResult $t-$m-$TIME
    done
done
