import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name='il-central-1')
    
    try:
        # Find instance by tag Name=ansible-Amit
        response = ec2.describe_instances(
            Filters=[
                {"Name": "tag:Name", "Values": ["ansible-Amit"]}
            ]
        )

        instance_ids = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instance_ids.append(instance['InstanceId'])

        if not instance_ids:
            return {
                "statusCode": 404,
                "body": "No EC2 instances found with tag Name=ansible-Amit"
            }

        # Start the instances
        ec2.start_instances(InstanceIds=instance_ids)

        return {
            "statusCode": 200,
            "body": f"Started EC2 instances: {instance_ids}"
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Error: {str(e)}"
        }
