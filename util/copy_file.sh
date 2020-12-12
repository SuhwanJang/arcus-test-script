#java
ip=211.249.63.38
#c_copy_file="standard_mix.c"
c_copy_file="standard_mix.c"
java_copy_file="torture_arcus_integration.java"
java_comdir="$HOME/arcus-misc-community/acp-java"
c_comdir="$HOME/arcus-misc-community/acp-c"

sshpass -p 'jam2in#' scp -P 11615 $java_comdir/$java_copy_file $ip:$java_comdir/
sshpass -p 'jam2in#' scp -P 11615 $c_comdir/$c_copy_file $ip:$c_comdir/

sshpass -p 'jam2in#' scp -P 11616 $java_comdir/$java_copy_file $ip:$java_comdir/
sshpass -p 'jam2in#' scp -P 11616 $c_comdir/$c_copy_file $ip:$c_comdir/
