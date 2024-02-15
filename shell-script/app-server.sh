#!/bin/bash
sudo yum update -y && sudo yum upgrade -y

sudo yum install java-1.8.0-amazon-corretto-devel -y
git clone https://github.com/aliasgarxo/app-java-jar.git /opt/

DB_ENDPOINT=$(terraform output -raw db_endpoint)
DB_USERNAME=$(terraform output -raw db_username)
DB_PASSWORD=$(terraform output -raw db_password)

export SPRING_DATASOURCE_URL="jdbc:mysql://${DB_ENDPOINT}:3306/userdata"
export SPRING_DATASOURCE_USERNAME=${DB_USERNAME} 
export SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}

java -Dserver.forward-headers-strategy=native -jar /opt/app-java-jar/validation-0.0.1-SNAPSHOT.jar