cd $HOME/arcus-memcached-EE-version
zookeeper=10.33.144.120:2181,10.33.145.182:2181,10.34.33.62:2181
port=11701
memory=800
version=0.8.0
cd $version
echo "jam2in#" | sudo -S make install
./memcached -d -v -r -X .libs/syslog_logger.so -X .libs/ascii_scrub.so -p $port -m $memory -z $zookeeper -E .libs/default_engine.so
cd ..

port=11801
version=0.7.8
cd $version
echo "jam2in#" | sudo -S make install
./memcached -d -v -r -X .libs/syslog_logger.so -X .libs/ascii_scrub.so -p $port -m $memory -z $zookeeper -E .libs/default_engine.so
