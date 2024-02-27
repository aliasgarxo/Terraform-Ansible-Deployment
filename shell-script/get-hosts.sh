#!/bin/bash

# Define your Auto Scaling group name
ASG_NAME="ASG-Application-Tier"

# Define the path to your Ansible hosts file
ANSIBLE_HOSTS="/opt/application/hosts.ini"

# Get the instance IDs of the instances in the Auto Scaling group
INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --query 'AutoScalingGroups[].Instances[].InstanceId' --output text)

# Add the application group to the Ansible hosts file
echo "[application]" > "$ANSIBLE_HOSTS"

# Initialize a counter
COUNTER=1

# Loop through the instance IDs
for INSTANCE_ID in $INSTANCE_IDS
do
  # Get the private IP address of the instance
  IP_ADDRESS=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[].Instances[].PrivateIpAddress' --output text)

  # Add the IP address to the Ansible hosts file in the specified format
  echo "server$COUNTER ansible_host=$IP_ADDRESS" >> "$ANSIBLE_HOSTS"

  # Increment the counter
  ((COUNTER++))
done

echo "[all:vars]" >> "$ANSIBLE_HOSTS"
echo "ansible_python_interpreter=/usr/bin/python3.9" >> "$ANSIBLE_HOSTS"
echo "ansible_ssh_private_key_file=/home/ec2-user/terra-keypair.pem" >> "$ANSIBLE_HOSTS"