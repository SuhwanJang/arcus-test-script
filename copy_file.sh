#java
ip=211.249.63.38
copy_file="config-arcus-integration.txt"
copy_source1="$HOME/arcus-misc-enterprise/acp-java"
copy_source2="$HOME/arcus-misc-community/acp-java"
#copy_target="arcus-misc/arcus-misc2/acp-java"

sshpass -p 'jam2in#' scp -P 11615 $copy_source1/$copy_file $ip:$copy_source1/
sshpass -p 'jam2in#' scp -P 11615 $copy_source2/$copy_file $ip:$copy_source2/

sshpass -p 'jam2in#' scp -P 11616 $copy_source1/$copy_file $ip:$copy_source1/
sshpass -p 'jam2in#' scp -P 11616 $copy_source2/$copy_file $ip:$copy_source2/
