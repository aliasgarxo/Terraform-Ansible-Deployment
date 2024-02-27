#!/bin/bash
sudo yum update -y && sudo yum upgrade -y
sudo yum install python3-pip -y
sudo pip3 install ansible boto3
mkdir /opt/application
touch /opt/application/hosts.ini
touch /opt/application/app.yaml
mkdir /opt/web-server
touch /opt/web-server/hosts.ini
touch /opt/web-server/web.yaml
while [ ! -f /home/ec2-user/provisioner_done.txt ]
do
  sleep 2
done
sudo /home/ec2-user/get-hosts.sh
sudo /home/ec2-user/get-hosts-web.sh