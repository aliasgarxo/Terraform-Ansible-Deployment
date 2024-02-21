#!/bin/bash

# Install AWS CLI (if not present)
if ! command -v aws &> /dev/null; then
  echo "AWS CLI not found. Installing..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  echo "AWS CLI installed successfully."
else
  echo "AWS CLI already installed."
fi

# Store credentials securely in the credentials file
mkdir -p ~/.aws 
echo "[default]" > ~/.aws/credentials
read -p "AWS Access Key ID: " access_key
echo "aws_access_key_id = $access_key" >> ~/.aws/credentials
read -sp "AWS Secret Access Key: " secret_key
echo "aws_secret_access_key = $secret_key" >> ~/.aws/credentials

echo "AWS credentials configured securely." 
