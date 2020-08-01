ZK_CLI="/home/long_running_replication/arcus/zookeeper/bin/zkCli.sh"
ZK_ADDR="-server 10.34.35.122:2195,10.34.32.171:2195,10.33.137.55:2195"

$ZK_CLI $ZK_ADDR create /arcus_repl 0

$ZK_CLI $ZK_ADDR create /arcus_repl/client_list 0
$ZK_CLI $ZK_ADDR create /arcus_repl/client_list/long_running_replication 0

$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_log 0

$ZK_CLI $ZK_ADDR create /arcus_repl/cache_list 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_list/long_running_replication 0
# ehpemeral znode = <group>^M^<ip:port-hostname> 0 // created by cache node
# ehpemeral znode = <group>^S^<ip:port-hostname> 0 // created by cache node

$ZK_CLI $ZK_ADDR create /arcus_repl/group_list 0
$ZK_CLI $ZK_ADDR create /arcus_repl/group_list/long_running_replication 0
$ZK_CLI $ZK_ADDR create /arcus_repl/group_list/long_running_replication/g0 0
$ZK_CLI $ZK_ADDR create /arcus_repl/group_list/long_running_replication/g1 0
$ZK_CLI $ZK_ADDR create /arcus_repl/group_list/long_running_replication/g2 0
$ZK_CLI $ZK_ADDR create /arcus_repl/group_list/long_running_replication/g3 0
$ZK_CLI $ZK_ADDR create /arcus_repl/group_list/long_running_replication/g4 0
$ZK_CLI $ZK_ADDR create /arcus_repl/group_list/long_running_replication/g5 0
# ehpemeral/sequence znode = <nodeip:port>^<listenip:port>^<sequence> 0
# ehpemeral/sequence znode = <nodeip:port>^<listenip:port>^<sequence> 0

$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.35.122:11700 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.35.122:11700/long_running_replication^g0^10.34.35.122:20700 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.32.171:11701 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.32.171:11701/long_running_replication^g0^10.34.32.171:20701 0

$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.32.171:11700 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.32.171:11700/long_running_replication^g1^10.34.32.171:20700 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.33.137.55:11701 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.33.137.55:11701/long_running_replication^g1^10.33.137.55:20701 0

$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.33.137.55:11700 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.33.137.55:11700/long_running_replication^g2^10.33.137.55:20700 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.35.122:11701 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.35.122:11701/long_running_replication^g2^10.34.35.122:20701 0

$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.35.122:11800 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.35.122:11800/long_running_replication^g3^10.34.35.122:20800 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.32.171:11801 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.32.171:11801/long_running_replication^g3^10.34.32.171:20801 0

$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.32.171:11800 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.32.171:11800/long_running_replication^g4^10.34.32.171:20800 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.33.137.55:11801 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.33.137.55:11801/long_running_replication^g4^10.33.137.55:20801 0

$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.33.137.55:11800 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.33.137.55:11800/long_running_replication^g5^10.33.137.55:20800 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.35.122:11801 0
$ZK_CLI $ZK_ADDR create /arcus_repl/cache_server_mapping/10.34.35.122:11801/long_running_replication^g5^10.34.35.122:20801 0
