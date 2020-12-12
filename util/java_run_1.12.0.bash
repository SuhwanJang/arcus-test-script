# Find os type. if system`s os is Mac OS X, we use greadlink.
case "$OSTYPE" in
  darwin*) DIR=`greadlink -f $0`;;
  *) DIR=`readlink -f $0`;;
esac

DIR=`dirname $DIR`
if test -d "$DIR/../../arcus-java-client-version/develop" ; then
    JAR_DIR=/home/jam2in/arcus-java-client-version/develop/target
    CP=$JAR_DIR/arcus-java-client-1.12.0.jar:$JAR_DIR/zookeeper-3.4.14.jar:$JAR_DIR/log4j-api-2.8.2.jar:$JAR_DIR/log4j-core-2.8.2.jar:$JAR_DIR/slf4j-api-1.7.24.jar:$JAR_DIR/log4j-slf4j-impl-2.8.2.jar
fi

echo "Jar directory:" $JAR_DIR

java -Xmx2g -Xms2g "-Dnet.spy.log.LoggerImpl=net.spy.memcached.compat.log.Log4JLogger" -classpath $CP:. acp $@
