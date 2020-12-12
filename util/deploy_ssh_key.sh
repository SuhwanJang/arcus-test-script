home="/home/test"
sshFile="$home/.ssh"
if [ -d "$sshFile" ]; then
  echo "exist ssh file"
else
  mkdir -p $sshFile
  chmod 700 $sshFile
  ssh-keygen -t rsa
fi

ssh-copy-id test@jam2in-s001
ssh-copy-id test@jam2in-s002
