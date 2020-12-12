# show switchover
echo "============================ switchover ============================"
ps -ef | grep -v "grep" | grep switchover | grep test
echo ""

# show acp_log_retention
echo "=========================== acp-log-retention =========================="
ps -ef | grep -v "grep" | grep acp_log_retention | grep test
echo ""
