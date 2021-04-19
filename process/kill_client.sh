source ./helper.sh

function kill_c_client {
  mtype=$1
  pids=($(ps -ef | grep -v "grep" | grep "acp-c/config-standard.txt" | grep "test" | awk '{ print $2 }'))
  if [ ${#pids[@]} -eq 0 ]; then
    return;
  fi
  for pid in "${pids[@]}"
  do
    ps_mtype=$(ls -al /proc/$pid/fd/1 | awk '{print $11}')
    if [[ $ps_mtype == *$mtype* ]]; then
      result=$(kill -9 $pid)
      echo "c client is killed. pid=$pid, host=$host, fd=$ps_mtype"
      break;
    fi
  done
}

function kill_java_client {
  mtype=$1
  pids=($(ps -ef | grep -v "grep" | grep "acp-java/config-arcus-integration.txt" | grep "acp -config" | grep $mtype | grep "test" | awk '{ print $2 }'))
  if [ ${#pids[@]} -eq 0 ]; then
    return;
  fi
  for pid in "${pids[@]}"
  do
    result=$(kill -9 $pid)
    echo "java client is killed. pid=$pid, host=$host"
  done
}

function kill_all_clients {
  kill_all_java_clients
  kill_all_c_clients
}

function kill_all_java_clients {
  kill_java_client "community"
  kill_java_client "enterprise"
}

function kill_all_c_clients {
  kill_c_client "community"
  kill_c_client "enterprise"
}

function ask_c_client {
  echo "Which c-client do you want to kill?"
  select input in "All" "Enterprise" "Community"; do
    case $input in
        All ) kill_all_c_clients; break;;
        Enterprise ) kill_c_client "enterprise"; break;;
        Community ) kill_c_client "community"; break;;
    esac
  done
}

function ask_java_client {
  echo "Which java-client do you want to kill?"
  select input in "All" "Enterprise" "Community"; do
    case $input in
        All ) kill_all_java_clients; break;;
        Enterprise ) kill_java_client "enterprise"; break;;
        Community ) kill_java_client "community"; break;;
    esac
  done
}

function ask {
  echo "Which client do you want to kill?"
  select input in "All" "C-Client" "Java-Client"; do
    case $input in
        All ) kill_all_clients; break;;
        C-Client ) ask_c_client; break;;
        Java-Client ) ask_java_client; break;;
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

echo -n "Are you sure you want to kill client on $host ?(y/n)"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
  ask
else
  exit;
fi
