cd $HOME/arcus-test-script
nohup ./switchover.bash 11700 11701 30 300 | ts >> switchover11700.out &
nohup ./switchover.bash 11800 11801 30 300 | ts >> switchover11800.out &
