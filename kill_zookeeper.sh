source ./helper.sh
function kill_zookeeper {
  pid=$(ps -ef | grep -v "grep" | grep "\-Dzookeeper.log.dir" | grep "/home/test/arcus/zookeeper" | grep "$username" | awk '{print $2}')
  if [ -n "$pid" ]; then
    result=$(kill -9 $pid)
    echo "zookeeper is killed. $ps host=$host"
  else
    echo "zookeeper is not found. $ps host=$host"
  fi
}

host=$(hostname -f)
[[ $1 ]] && host=$1
if [ "$host" != $(hostname -f) ]; then
  transfer_file $host "$(basename "$0")"
  ssh $username@$host "cd $HOME/arcus-test-script; ./$(basename "$0");"
  exit;
fi

echo -n "Are you sure you want to kill zookeeper on $host ?(y/n)"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
  kill_zookeeper
else
  exit;
fi
