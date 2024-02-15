#!/bin/bash
sudo yum update -y && sudo yum upgrade -y

sudo yum install java-1.8.0-amazon-corretto-devel

DB_ENDPOINT=$(terraform output -raw db_endpoint)
java -Dserver.forward-headers-strategy=native -jar /opt/app.jar