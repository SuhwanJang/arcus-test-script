tdir=$HOME/arcus-test-script
cd $tdir/control
rm -rf $tdir/logs/switchover11700.out
rm -rf $tdir/logs/switchover11800.out
nohup ./switchover.bash 11700 11701 30 300 jam2in-s001 | ts >> $tdir/logs/switchover11700.out &
nohup ./switchover.bash 11800 11801 30 300 jam2in-s001 | ts >> $tdir/logs/switchover11800.out &
