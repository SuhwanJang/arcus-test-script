user=$USER
hostname=$(hostname)
testlogdir="$PWD/log"
CONFFILE="param.json"
test_restart=$(jq -r '.test_restart' $CONFFILE)

# arcus persistence.
engine_config=$(jq -r '.engine_config' $CONFFILE)
logpath=$(jq -r '.logpath' $CONFFILE)
datapath=$(jq -r '.datapath' $CONFFILE)

# memtier_benchmark parameters.
test_restart=$(jq -r '.test_restart' $CONFFILE)
client=$(jq -r '.client' $CONFFILE)
server=$(jq -r '.server' $CONFFILE)
port=$(jq -r '.port' $CONFFILE)
server_type=$(jq -r '.server_type' $CONFFILE)
server_mode=$(jq -r '.server_mode' $CONFFILE)
threads=$(jq -r '.threads' $CONFFILE)
clients=$(jq -r '.clients' $CONFFILE)
keymaximum=$(jq -r '.keymaximum' $CONFFILE)
keyminimum=$(jq -r '.keyminimum' $CONFFILE)
data_size=$(jq -r '.data_size' $CONFFILE)
client_mode=$(jq -r '.client_mode' $CONFFILE)
run_count=$(jq -r '.run_count' $CONFFILE)
requests=$((keymaximum/(clients*threads)))

function printconfig() {
    echo "Config File : $CONFFILE"
    cat $CONFFILE
}
