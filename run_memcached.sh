source ./helper.sh 
function run_memcached {
  memlimit=$(read_memlimit)
  mtype=$1
  port=$2
  version=$(get_version $host $mtype $port)
  echo "port=$port version=$version"
  if [ $mtype == "community" ]; then
    cd $HOME/arcus-memcached-version/$version
  else
    cd $HOME/arcus-memcached-EE-version/$version
  fi
  ./memcached -d -v -r -I 3M -X .libs/syslog_logger.so -X .libs/ascii_scrub.so -p $port -m $memlimit -z $zookeeper -E .libs/default_engine.so
  cd $HOME
}

function run_community_memcached {
# run all community memcached
  IFS=',' read -r -a array <<< "$community_ports"
  for port in "${array[@]}"
  do
    run_memcached "community" $port
  done
}

function run_enterprise_master_memcached {
# run all enterprise master memcached
  IFS=',' read -r -a array <<< "$enterprise_master_ports"
  for port in "${array[@]}"
  do
    run_memcached "enterprise-master" $port
  done
}

function run_enterprise_slave_memcached {
# run all enterprise slave memcached
  IFS=',' read -r -a array <<< "$enterprise_slave_ports"
  for port in "${array[@]}"
  do
    run_memcached "enterprise-slave" $port
  done
}

function run_all_memcached {
  run_community_memcached
  run_enterprise_master_memcached
  run_enterprise_slave_memcached
}

function ask {
  echo "Which memcached do you want to run?"
  select input in "All" "Community" "EnterpriseMaster" "EnterpriseSlave"; do
    case $input in
        All ) run_all_memcached; break;;
        Community ) run_community_memcached; break;;
        EnterpriseMaster ) run_enterprise_master_memcached; break;;
        EnterpriseSlave ) run_enterprise_slave_memcached; break;;
    esac
  done
}

host=$(hostname -f)
[[ $1 ]] && host=$1
if [ "$host" != $(hostname -f) ]; then
  transfer_file $host "$(basename "$0")"
  ssh $username@$host "cd $HOME/arcus-test-script; ./$(basename "$0");"
  exit;
fi

echo -n "Are you sure you want to run memcached on $host ?(y/n)"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
  ask
else
  exit;
fi
