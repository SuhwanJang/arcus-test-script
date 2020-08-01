ZK_CLI="/home/test/arcus/zookeeper/bin/zkCli.sh"
ZK_ADDR="-server 10.34.35.122:2195,10.34.32.171:2195,10.33.137.55:2195"

$ZK_CLI $ZK_ADDR create /arcus 0

$ZK_CLI $ZK_ADDR create /arcus/client_list 0
$ZK_CLI $ZK_ADDR create /arcus/client_list/long_running_community 0

$ZK_CLI $ZK_ADDR create /arcus/cache_server_log 0

$ZK_CLI $ZK_ADDR create /arcus/cache_list 0
$ZK_CLI $ZK_ADDR create /arcus/cache_list/long_running_community 0
# ehpemeral znode = <group>^M^<ip:port-hostname> 0 // created by cache node
# ehpemeral znode = <group>^S^<ip:port-hostname> 0 // created by cache node

$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.34.35.122:11500 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.34.35.122:11500/long_running_community^10.34.35.122:20500 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.34.35.122:11501 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.34.35.122:11501/long_running_community^10.34.35.122:20501 0

$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.34.32.171:11500 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.34.32.171:11500/long_running_community^10.34.32.171:20500 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.34.32.171:11501 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.34.32.171:11501/long_running_community^10.34.32.171:20501 0

$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.33.137.55:11500 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.33.137.55:11500/long_running_community^10.33.137.55:20500 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.33.137.55:11501 0
$ZK_CLI $ZK_ADDR create /arcus/cache_server_mapping/10.33.137.55:11501/long_running_community^10.33.137.55:20501 0
