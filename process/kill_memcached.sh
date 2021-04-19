source ./helper.sh
function kill_memcached {
  pid=$(ps -ef | grep "./memcached" | grep "$zkensemble" | grep "$1" | grep "$username" | awk '{print $2}')
  if [ -n "$pid" ]; then
    result=$(kill $pid)
    echo "memcached is killed. port=$1 host=$host"
  else
    echo "memcached is not found. port=$1 host=$host"
  fi
}

function kill_community_memcached {
# kill all community memcached
  IFS=',' read -r -a array <<< "$community_ports"
  for port in "${array[@]}"
  do
    kill_memcached $port
  done
}

function kill_enterprise_memcached {
# kill all community memcached
  IFS=',' read -r -a array <<< "$enterprise_ports"
  for port in "${array[@]}"
  do
    kill_memcached $port
  done
}

function kill_all_memcached {
  kill_community_memcached
  kill_enterprise_memcached
}

function ask {
  echo "Which memcached do you want to kill?"
  select input in "All" "Community" "Enterprise"; do
    case $input in
        All ) kill_all_memcached; break;;
        Community ) kill_community_memcached; break;;
        Enterprise ) kill_enterprise_memcached; break;;
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

echo -n "Are you sure you want to kill memcached on $host ?(y/n)"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
  ask
else
  exit;
fi
