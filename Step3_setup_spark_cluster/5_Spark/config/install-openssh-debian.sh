#!/bin/bash
export PATH=/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
apt-get update -y && apt-get upgrade -y
apt-get install -y systemd
apt-get install -y openssh-server

sed -i '/StrictHostKeyChecking/s/^#[ \t]*//g' /etc/ssh/ssh_config
sed -i 's/StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config
sed -i 's/StrictHostKeyChecking True/StrictHostKeyChecking no/g' /etc/ssh/ssh_config
cat /etc/ssh/ssh_config | grep StrictHostKeyChecking

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
cat /etc/ssh/sshd_config | grep PermitRootLogin
cat /etc/ssh/sshd_config | grep PasswordAuthentication

sudo service ssh start
service ssh restart
service ssh status