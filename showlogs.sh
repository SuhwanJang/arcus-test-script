CASES=( "onlySet" "onlyGetRandom" "onlyGetLongtail" "GetSetRandom(1:9)" "GetSetRandom(3:7)" )

function getResult() {
    array=$(find ./* -name $1)
    for x in ${array[@]}; do
        for case in ${CASES[@]}; do
            echo -e "\n========== $1-$case =========="
            cat $x/$case/result.log | grep -A 1 "Hubble*"
            cat $x/$case/memtier.log | grep -A 8 "ALL"
            #if [[ "$case" != "onlyGetRandom" ]]; then
            cat $x/$case/result.log | grep -B 5 "System"
            #fi
        done
    done
}

function getHubble() {
    array=$(find ./* -name $1)
    for x in ${array[@]}; do
        echo ======= $x
        cat $x/result.log | grep -A 1 "Hubble*"
    done
}

function getMemtierResult() {
    array=$(find ./* -name $1)
    for x in ${array[@]}; do
        echo ======= $x
        cat $x/memtier.log | grep -A 8 "ALL"
    done
}

#getHubble onlySet
#getHubble onlyGetRandom
#getHubble GetSetRandom*3*

echo "off"
getResult *arcus-off*
getResult *redis-off*

echo "async"
getResult *arcus-async*
getResult *redis-async*

echo "sync"
getResult *arcus-sync*
getResult *redis-sync*

