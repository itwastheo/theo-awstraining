import boto3

def lambda_handler(event, context):
    ec2 = boto3.client("ec2", region_name="eu-west-2")  # Update with your AWS region

    response = ec2.run_instances(
        ImageId="ami-0c55b159cbfafe1f0",  # Amazon Linux 2 AMI (update as needed)
        InstanceType="t2.micro",
        KeyName="my-key-pair",  # Change to your actual key pair
        MinCount=1,
        MaxCount=1,
        TagSpecifications=[
            {
                "ResourceType": "instance",
                "Tags": [{"Key": "AutoSchedule", "Value": "True"}]
            }
        ]
    )

    instance_id = response["Instances"][0]["InstanceId"]
    return {"message": f"EC2 Instance {instance_id} launched successfully!"}
