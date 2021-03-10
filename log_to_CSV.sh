# we have no redis monitoring.
# this makes ops/latency CSV file from memtier log, so you can transform CSV file into chart.
DATE="2021-04-19"
TIME="14:55:04"
TYPES=( "arcus" )
MODES=( "off" "async" "sync" )
CASES=( "onlySet" "onlyGetRandom" "onlyGetLongtail" )
CSVDIR="csv"

if [ -d "$CSVDIR" ]; then
    :
else
    mkdir $CSVDIR
fi

function processing() {
    SAVEIFS=$IFS   # Save current IFS
    IFS=$'\n'      # Change IFS to new line
    ops=($(grep "ops\/sec" $1)) # split to array $names
    IFS=$SAVEIFS   # Restore IFS

    echo -e "time\tops\tlatency" > $CSVDIR/$2
    i=1
    for x in "${ops[@]}"; do
        op=$(echo $x | awk '{ print $10 }')
        latency=$(echo $x | awk '{ print $17 }')
        printf "$i\t$op\t$latency\n" >> $CSVDIR/$2
        ((i++))
    done
}

function processing_average() {
    SAVEIFS=$IFS   # Save current IFS
    IFS=$'\n'      # Change IFS to new line
    ops=($(grep "ops\/sec" $1)) # split to array $names
    IFS=$SAVEIFS   # Restore IFS
    echo -e "time\tops\tlatency" > $CSVDIR/$2
    i=1
    v=0
    cnt=0
    avg=5
    for x in "${ops[@]}"; do
        if [[ $cnt == $avg ]]; then
            v=$(($v / $avg))
            latency=$(echo $x | awk '{ print $17 }')
            printf "$i\t$v\t$latency\n" >> $CSVDIR/$2
            ((i++))
            v=0
            cnt=0
        fi
        op=$(echo $x | awk '{ print $10 }')
        v=$(($op + $v))
        cnt=$(($cnt + 1))
    done
}

function makeCSV() {
    array=$(find ./log/$DATE/* -name $1)
    for x in ${array[@]}; do
        for case in ${CASES[@]}; do
            fname=$x/$case/memtier.log
            if [ -f "$fname" ]; then
                processing_average $x/$case/memtier.log $1_$case.csv
            else
                echo "$fname not exist"
            fi
        done
    done
}

for t in ${TYPES[@]}; do
    for m in ${MODES[@]}; do
        makeCSV $t-$m-$TIME
    done
done

