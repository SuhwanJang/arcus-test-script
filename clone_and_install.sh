home="/home/test"
arcus_dir="$home/arcus"
clone_EE=0
clone_open=0
clone_java=0
clone_c=0
clone_misc=1

if [ -d "$arcus_dir" ]; then
  echo "arcus exists"
else
  echo -e "no arcus project.. install it"
  cd $home
  cloneCmd="git clone https://github.com/naver/arcus.git"
  cloneCmdRun=$($cloneCmd 2>&1)
  echo -e "Running: \n$ $cloneCmd"
  echo -e "${cloneCmdRun}\n\n"
  cd "$arcus_dir/scripts"
  ./build.sh
  cd $home
fi

if [ $clone_open = 1 ]
then
  mkdir -p $HOME/arcus-memcached-version
  cd $HOME/arcus-memcached-version

  #clone arcus-memcached-$version
  versions=("develop")
  for version in "${versions[@]}"; do
    if [ -d "$version" ]; then
        echo "arcus-memcached $version exist"
        #continue
        rm -rf $version
    fi
    cloneCmd="git clone -b $version https://github.com/naver/arcus-memcached.git $version"
    if [ $version = "develop" ]; then
	cloneCmd="git clone https://github.com/naver/arcus-memcached.git $version"
    fi
    cloneCmdRun=$($cloneCmd 2>&1)
    echo -e "Running: \n$ $cloneCmd"
    echo -e "${cloneCmdRun}\n\n"
    cd $version
    if [ $version = "develop" ]; then
      git checkout develop
    fi
    ./config/autorun.sh
    ./configure --prefix=$arcus_dir --enable-zk-integration --with-libevent=$arcus_dir --with-zookeeper=$arcus_dir
    make
    cd ..
  done
fi

if [ $clone_EE = 1 ]
then
  mkdir -p $HOME/arcus-memcached-EE-version
  cd $HOME/arcus-memcached-EE-version

  #clone arcus-memcached-EE-$version
  versions=("develop" "0.8.1-E" "0.8.0-E" "0.7.8-E")
  for version in "${versions[@]}"; do
    if [ -d "$version" ]; then
        echo "arcus-memcached-EE $version exist"
        #continue
        rm -rf $version
    fi
    cloneCmd="git clone -b $version https://github.com/jam2in/arcus-memcached-EE.git $version"
    if [ $version = "develop" ]; then
	cloneCmd="git clone https://github.com/jam2in/arcus-memcached-EE.git $version"
    fi
    cloneCmdRun=$($cloneCmd 2>&1)
    echo -e "Running: \n$ $cloneCmd"
    echo -e "${cloneCmdRun}\n\n"
    cd $version
    if [ $version = "develop" ]; then
      git checkout memc_repl_dev
    fi
    ./config/autorun.sh
    ./configure --prefix=$arcus_dir --enable-zk-integration --with-libevent=$arcus_dir --with-zookeeper=$arcus_dir --enable-replication
    sed -i "s/^AM_CFLAGS.*/AM_CFLAGS = -fvisibility=hidden -pthread -g -O2 -Wall -Werror -pedantic -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls -fno-strict-aliasing/g" Makefile
    make
    cd ..
  done
fi

if [ $clone_java = 1 ]
then
  mkdir -p $HOME/arcus-java-client-version
  cd $HOME/arcus-java-client-version

  #clone arcus-java-client-$version
  versions=("develop" "1.12.0" "1.11.5" "1.11.4")
  for version in "${versions[@]}"; do
    if [ -d "$version" ]; then
        echo "arcus-java-client $version exist"
        rm -rf $version
        #continue
    fi
    cloneCmd="git clone -b $version https://github.com/naver/arcus-java-client.git $version"
    if [ $version = "develop" ]; then
	cloneCmd="git clone https://github.com/naver/arcus-java-client.git $version"
    fi
    cloneCmdRun=$($cloneCmd 2>&1)
    echo -e "Running: \n$ $cloneCmd"
    echo -e "${cloneCmdRun}\n\n"
    cd $version
    if [ $version = "develop" ]; then
      git checkout develop
    fi
    mvn clean install -DskipTests=true
    cd ..
  done
  cd $HOME
fi

if [ $clone_c = 1 ]
then
  mkdir -p $HOME/arcus-c-client-version
  cd $HOME/arcus-c-client-version

  #clone arcus-c-client-$version
  versions=("develop" "1.12.0")
  for version in "${versions[@]}"; do
    if [ -d "$version" ]; then
        echo "arcus-c-client $version exist"
        rm -rf $version
        #continue
    fi
    cloneCmd="git clone -b $version https://github.com/naver/arcus-c-client.git $version"
    if [ $version = "develop" ]; then
	cloneCmd="git clone https://github.com/naver/arcus-c-client.git $version"
    fi
    cloneCmdRun=$($cloneCmd 2>&1)
    echo -e "Running: \n$ $cloneCmd"
    echo -e "${cloneCmdRun}\n\n"
    cd $version
    if [ $version = "develop" ]; then
      git checkout develop
    fi
    ./config/autorun.sh
    ./configure --prefix=$arcus_dir --enable-zk-integration --with-zookeeper=$arcus_dir
    make
    sudo make install
    cd ..
  done
fi

if [ $clone_misc = 1 ]
then
  cd $HOME
  filename="arcus-misc-enterprise"
  if [ -d "$filename" ]; then
    echo "$filename folder exists"
  else
    cloneCmd="git clone https://github.com/SuhwanJang/arcus-misc.git $filename"
    cloneCmdRun=$($cloneCmd 2>&1)
    echo -e "Running: \n$ $cloneCmd"
    echo -e "${cloneCmdRun}\n\n"
    cd $filename
  fi
  cd $HOME
  filename="arcus-misc-community"
  if [ -d "$filename" ]; then
    echo "$filename folder exists"
  else
    cloneCmd="git clone https://github.com/SuhwanJang/arcus-misc.git $filename"
    cloneCmdRun=$($cloneCmd 2>&1)
    echo -e "Running: \n$ $cloneCmd"
    echo -e "${cloneCmdRun}\n\n"
    cd $filename
  fi
fi
