client_logdir="/data/long_running_test_logs"
filename="test_parameter.txt"
filedir="$HOME/arcus-test-script"
read_line=""
function read_test_parameter {
  if [ ! -f "$filename" ]; then
    echo "$filename is not exist";
    exit;
  fi
  while read line
  do
    if [[ "$line" == $1* ]]; then
      read_line="$line"
      break;
    fi
  done < $filename
}

function read_host {
  keyword="host="
  read_test_parameter $keyword
  echo "${read_line#"$keyword"}"
}

function get_hostport {
  for host in "${local_hostarray[@]}"
  do
    if [[ "$host" == $1* ]]; then
      echo "${host#"$1:"}"
      break;
    fi
  done
}

function get_memcached_version {
  echo "$(jq -r --arg hostname "$1" --arg mtype "$2" --arg port "$3" '.[$hostname][] | .[$mtype][] | select(.port==$port) .version' $filedir/memcached.json)"
}

function get_client_version {
  echo "$(jq -r --arg hostname "$1" --arg mtype "$2" --arg client "$3" '.[$hostname][] | .[$client][] | select(.type == $mtype) .version' $filedir/client.json)"
}

function read_memlimit {
  keyword="memlimit="
  read_test_parameter $keyword
  echo "${read_line#"$keyword"}"
}

function read_zookeeper {
  keyword="zookeeper="
  read_test_parameter $keyword
  echo "${read_line#"$keyword"}"
}

function read_username {
  keyword="username="
  read_test_parameter $keyword
  echo "${read_line#"$keyword"}"
}

function read_community_ports {
  keyword="community_ports="
  read_test_parameter $keyword
  echo "${read_line#"$keyword"}"
}

function read_enterprise_ports {
  keyword="enterprise_ports="
  read_test_parameter $keyword
  echo "${read_line#"$keyword"}"
}

function read_enterprise_master_ports {
  keyword="enterprise_master_ports="
  read_test_parameter $keyword
  echo "${read_line#"$keyword"}"
}

function read_enterprise_slave_ports {
  keyword="enterprise_slave_ports="
  read_test_parameter $keyword
  echo "${read_line#"$keyword"}"
}

function transfer_file {
  scp -P $(get_hostport $1) "client.json" $username@211.249.63.38:/$filedir
  scp -P $(get_hostport $1) "memcached.json" $username@211.249.63.38:/$filedir
  scp -P $(get_hostport $1) "helper.sh" $username@211.249.63.38:/$filedir
  scp -P $(get_hostport $1) "test_parameter.txt" $username@211.249.63.38:/$filedir
  scp -P $(get_hostport $1) $2 $username@211.249.63.38:/$filedir
}

zookeeper=$(read_zookeeper)
username=$(read_username)
community_ports=$(read_community_ports)
enterprise_ports=$(read_enterprise_ports)
enterprise_master_ports=$(read_enterprise_master_ports)
enterprise_slave_ports=$(read_enterprise_slave_ports)

local_host=$(read_host)
IFS=',' read -r -a local_hostarray <<< "$local_host"

#DEBUG
#get_memcached_version "jam2in-m001" "enterprise-master" "11500"
#get_client_version "jam2in-s002" "enterprise" "c"
