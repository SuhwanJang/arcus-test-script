# show acp-c
echo "============================ acp-c ============================"
ps -ef | grep -v "grep" | grep acp-c | grep test
echo ""

# show acp-java
echo "=========================== acp-java =========================="
ps -ef | grep -v "grep" | grep acp-java | grep test
echo ""

# show arcus-memcached
echo "========================== arcus-memcached ======================="
ps -ef | grep -v "grep" | grep memcached | grep default_engine.so | grep test
echo ""

# show arcus-zookeeper
echo "========================== arcus-zookeeper ======================="
ps -ef | grep -v "grep" | grep zookeeper | grep zoo.cfg | grep test
echo ""

