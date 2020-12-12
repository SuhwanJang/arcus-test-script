source ./helper.sh
COMMUNITY_DIR="$HOME/arcus-misc-community"
ENTERPRISE_DIR="$HOME/arcus-misc-enterprise"
COMMUNITY_SERVICE_CODE="long_running_community"
ENTERPRISE_SERVICE_CODE="long_running_replication"
service_code=""
client=5
rate=200
request=0
ttime=0
key_prefix=""
keyset_size=50000
valueset_min_size=50
valueset_max_size=100
pool=1
pool_size=16
config=""
client_profile=""

function setting_config {
 ## config file
  echo "config setting.. config=$config"
  sed -i "s/^zookeeper=.*/zookeeper=$zookeeper/" $DIR1/$config
  sed -i "s/^service_code=.*/service_code=$service_code/" $DIR1/$config
  sed -i "s/^client_profile=.*/client_profile=$client_profile/" $DIR1/$config
  sed -i "s/^client=.*/client=$client/" $DIR1/$config
  sed -i "s/^rate=.*/rate=$rate/" $DIR1/$config
  sed -i "s/^request=.*/request=$request/" $DIR1/$config
  sed -i "s/^time=.*/time=$ttime/" $DIR1/$config
  sed -i "s/^key_prefix=.*/key_prefix=$key_prefix/" $DIR1/$config
  sed -i "s/^keyset_size=.*/keyset_size=$keyset_size/" $DIR1/$config
  sed -i "s/^valueset_min_size=.*/valueset_min_size=$valueset_min_size/" $DIR1/$config
  sed -i "s/^valueset_max_size=.*/valueset_max_size=$valueset_max_size/" $DIR1/$config
  sed -i "s/^pool_size=.*/pool_size=$pool_size/" $DIR1/$config
  sed -i "s/^pool=.*/pool=$pool/" $DIR1/$config
}

function run_c_client {
  key_prefix="c-$host:"
  arcus_dir="$HOME/arcus"
  configname="config-standard.txt"
  client_profile="standard_mix"
  pool_size=32
  mtype=$1
  local dir=""
  if [ $mtype == "community" ]; then
    dir="$COMMUNITY_DIR/acp-c"
    service_code=$COMMUNITY_SERVICE_CODE
  else
    dir="$ENTERPRISE_DIR/acp-c"
    service_code=$ENTERPRISE_SERVICE_CODE
  fi
  config="$dir/$configname"
  setting_config

  sed -i "s/^BASEDIR.*/BASEDIR=\/home\/test\/arcus/" $dir/Makefile

  cdir=$HOME/arcus-c-client-version
  version=$(get_client_version $host $mtype "c")
  echo "install c-client in $cdir/$version"
  cd $cdir/$version
  ./config/autorun.sh
  ./configure --prefix=$arcus_dir --enable-zk-integration --with-zookeeper=$arcus_dir
  make clean; make
  echo "jam2in#" | sudo -S make install
  cd $dir
  make

  logpath="$client_logdir/$mtype/c/nohup.out"
  echo "run acp-c with nohup. path=$dir host=$host version=$version logpath=$logpath"
  cd $dir
  nohup ./acp -config $config >> $logpath &
  sleep 10
}

function run_java_client {
  key_prefix="java-$host:"
  configname="config-arcus-integration.txt"
  client_profile="torture_arcus_integration"
  pool_size=16
  mtype=$1
  local dir=""
  if [ $mtype == "community" ]; then
    dir="$COMMUNITY_DIR/acp-java"
    service_code=$COMMUNITY_SERVICE_CODE
  else
    dir="$ENTERPRISE_DIR/acp-java"
    service_code=$ENTERPRISE_SERVICE_CODE
  fi
  config="$dir/$configname"
  setting_config

  javadir=$HOME/arcus-java-client-version
  version=$(get_client_version $host $mtype "java")
  echo "install java-client in $javadir/$version"
  cd $javadir/$version
  #mvn clean install -DskipTests=true
  cd $dir
  ./compile.bash

  logpath="$client_logdir/$mtype/java/nohup.out"
  echo "run acp-java with nohup. path=$dir host=$host version=$version logpath=$logpath"
  cd $dir
  nohup ./run.bash -config $config | ts >> $logpath &
  sleep 10
}

function run_all_clients {
  run_all_java_clients
  run_all_c_clients
}

function run_all_java_clients {
  run_java_client "community"
  run_java_client "enterprise"
}

function run_all_c_clients {
  run_c_client "community"
  run_c_client "enterprise"
}

function ask_c_client {
  echo "Which c-client do you want to run?"
  select input in "All" "Enterprise" "Community"; do
    case $input in
        All ) run_all_c_clients; break;;
        Enterprise ) run_c_client "enterprise"; break;;
        Community ) run_c_client "community"; break;;
    esac
  done
}

function ask_java_client {
  echo "Which java-client do you want to run?"
  select input in "All" "Enterprise" "Community"; do
    case $input in
        All ) run_all_java_clients; break;;
        Enterprise ) run_java_client "enterprise"; break;;
        Community ) run_java_client "community"; break;;
    esac
  done
}

function ask {
  echo "Which client do you want to run?"
  select input in "All" "C-Client" "Java-Client"; do
    case $input in
        All ) run_all_clients; break;;
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

echo -n "Are you sure you want to run client on $host ?(y/n)"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
  ask
else
  exit;
fi
