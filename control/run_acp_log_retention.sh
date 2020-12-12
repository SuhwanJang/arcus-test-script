tdir=$HOME/arcus-test-script
cd $tdir/control
rm -rf $tdir/logs/acp_log_retention.out
nohup ./acp_log_retention.sh | ts > $tdir/logs/acp_log_retention.out &
