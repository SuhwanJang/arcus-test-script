CONFFILE="param.json"
server=$(jq -r '.server' $CONFFILE)
remote=$(jq -r '.remote' $CONFFILE)
user=$USER
hostname=$(hostname)
remote=$(jq -r '.remote' $CONFFILE)
port=$(jq -r '.port' $CONFFILE)
server_type=$(jq -r '.server_type' $CONFFILE)
server_mode=$(jq -r '.server_mode' $CONFFILE)
threads=$(jq -r '.threads' $CONFFILE)
clients=$(jq -r '.clients' $CONFFILE)
keymaximum=$(jq -r '.keymaximum' $CONFFILE)
keyminimum=$(jq -r '.keyminimum' $CONFFILE)
data_size=$(jq -r '.data_size' $CONFFILE)
client_mode=$(jq -r '.client_mode' $CONFFILE)
requests=$((keymaximum/(clients*threads)))

function printconfig() {
    echo "Config File : $CONFFILE"
    cat $CONFFILE
}
