ip=211.249.63.38
copy_file="torture_arcus_integration.java"
copy_source="arcus-misc/arcus-misc1/acp-java"
copy_target="arcus-misc/arcus-misc2/acp-java"
cp $copy_source/$copy_file $copy_target

sshpass -p 'jam2in#' scp -P 11621 $copy_source/$copy_file $ip:$copy_source/acp-java/
sshpass -p 'jam2in#' scp -P 11621 $copy_source/$copy_file $ip:$copy_target/acp-java/

sshpass -p 'jam2in#' scp -P 11622 $copy_source/$copy_file $ip:$copy_source/acp-java/
sshpass -p 'jam2in#' scp -P 11622 $copy_source/$copy_file $ip:$copy_target/acp-java/
