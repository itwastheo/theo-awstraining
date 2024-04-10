#!/bin/bash

# Variables
KEY_PAIR_NAME="your-key-pair-name"
SECURITY_GROUP_NAME="your-security-group-name"
INSTANCE_TYPE="t2.micro"
AMI_ID="your-ami-id"
USER_NAME="ec2-user"
PUBLIC_IP=""

# Launch EC2 instance
echo "Launching EC2 instance..."
instance_info=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_PAIR_NAME \
  --security-groups $SECURITY_GROUP_NAME \
  --query 'Instances[0].[InstanceId,PublicIpAddress]' \
  --output text)

INSTANCE_ID=$(echo $instance_info | cut -d' ' -f1)
PUBLIC_IP=$(echo $instance_info | cut -d' ' -f2)

echo "Instance $INSTANCE_ID is launching..."

# Wait for instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance $INSTANCE_ID is now running with public IP $PUBLIC_IP"

# SSH into the instance and perform configuration tasks
echo "SSHing into the instance..."
ssh_command="ssh -i your-key.pem $USER_NAME@$PUBLIC_IP"

# Example configuration tasks
$ssh_command "sudo yum update -y"
$ssh_command "sudo yum install telnet -y"
$ssh_command "echo 'Instance setup complete.'"

echo "EC2 setup and configuration complete."
