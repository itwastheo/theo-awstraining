import boto3

def lambda_handler(event, context):
    ec2 = boto3.client("ec2", region_name="eu-west-2")

    # Get instances tagged with AutoSchedule=True
    instances = ec2.describe_instances(Filters=[{"Name": "tag:AutoSchedule", "Values": ["True"]}])

    for reservation in instances["Reservations"]:
        for instance in reservation["Instances"]:
            instance_id = instance["InstanceId"]
            state = instance["State"]["Name"]
            
            if state == "running":
                ec2.stop_instances(InstanceIds=[instance_id])
                print(f"Stopped instance: {instance_id}")
            
            elif state == "stopped":
                ec2.start_instances(InstanceIds=[instance_id])
                print(f"Started instance: {instance_id}")
            
            else:
                print(f"Skipped instance {instance_id} (state: {state})")
