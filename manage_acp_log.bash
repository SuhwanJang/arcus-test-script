# screen log of arcus-misc1 is stored at arucs-misc2.
logfile=/home/jam2in/arcus-misc/arcus-misc1/acp-java/nohup.out
host=10.33.145.182
limit=300
while true;
do
    c1=$(echo stats | nc 10.33.145.182 11700 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c2=$(echo stats | nc 10.33.145.182 11701 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c3=$(echo stats | nc 10.33.145.182 11800 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c4=$(echo stats | nc 10.33.145.182 11801 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c5=$(echo stats | nc 10.33.144.120 11800 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c6=$(echo stats | nc 10.33.144.120 11801 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c7=$(echo stats | nc 10.33.144.120 11700 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c8=$(echo stats | nc 10.33.144.120 11701 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c9=$(echo stats | nc 10.34.33.62 11700 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c10=$(echo stats | nc 10.34.33.62 11701 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c11=$(echo stats | nc 10.34.33.62 11800 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)
    c12=$(echo stats | nc 10.34.33.62 11801 | grep curr_connection | tr -d '\r' | cut -d' ' -f3)

    if [ "$c1" -lt "$limit" ] && [ "$c2" -lt "$limit" ] && [ "$c3" -lt "$limit" ] && [ "$c4" -lt "$limit" ] && [ "$c5" -lt "$limit" ] && [ "$c6" -lt "$limit" ] && [ "$c7" -lt "$limit" ] && [ "$c8" -lt "$limit" ] && [ "$c9" -lt "$limit" ] && [ "$c10" -lt "$limit" ] && [ "$c11" -lt "$limit" ] && [ "$c12" -lt "$limit" ]
    then
        # truncate
        $(: > logfile)
    fi
    $(: > logfile)
    sleep 1800
done
