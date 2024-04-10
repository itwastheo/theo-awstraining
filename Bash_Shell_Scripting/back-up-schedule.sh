#!/bin/bash

# AWS CLI profile name
AWS_PROFILE="your_profile_name"

# AWS region where your EC2 instance resides
AWS_REGION="your_aws_region"

# EC2 instance ID
INSTANCE_ID="your_instance_id"

# Backup retention period in days
RETENTION_PERIOD=7

# Function to create EC2 instance backup
create_backup() {
    echo "Creating backup of EC2 instance $INSTANCE_ID..."
    aws ec2 create-image --instance-id "$INSTANCE_ID" --name "Backup-$(date +"%Y-%m-%d-%H-%M-%S")" --no-reboot --region "$AWS_REGION" --profile "$AWS_PROFILE"
}

# Function to delete old backups
delete_old_backups() {
    echo "Deleting backups older than $RETENTION_PERIOD days..."
    old_backups=$(aws ec2 describe-images --owners self --query "Images[?CreationDate<='$((($(date +%s) - $RETENTION_PERIOD*24*3600)*1000))'].ImageId" --output text --region "$AWS_REGION" --profile "$AWS_PROFILE")
    for image_id in $old_backups; do
        aws ec2 deregister-image --image-id "$image_id" --region "$AWS_REGION" --profile "$AWS_PROFILE"
        aws ec2 delete-snapshot --snapshot-id $(aws ec2 describe-images --image-ids "$image_id" --query "Images[0].BlockDeviceMappings[0].Ebs.SnapshotId" --output text --region "$AWS_REGION" --profile "$AWS_PROFILE") --region "$AWS_REGION" --profile "$AWS_PROFILE"
    done
}

# Main function
main() {
    create_backup
    delete_old_backups
}

# Execute the main function
main
