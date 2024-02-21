#!/bin/bash
sudo yum update -y && sudo yum upgrade -y
sudo yum install python3-pip -y
sudo pip3 install ansible boto3
sudo yum install awscli
