import json
import boto3
import uuid
from datetime import datetime

# Initialize DynamoDB and S3 clients
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# DynamoDB table name
TABLE_NAME = 'imtech'  # Replace with your DynamoDB table name
# BUCKET_NAME = 'imtech-amit-shimi-hagever'  # Replace with your S3 bucket name
# OBJECT_KEY = 'net_stats.json'  # The object key for the JSON file in S3

# Reference the DynamoDB table
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
        # Fetch the JSON file from S3
        # response = s3.get_object(Bucket=BUCKET_NAME, Key=OBJECT_KEY)
        
        # Read the content of the file
        # content = response['Body'].read().decode('utf-8')

        body = event.get("body")
        if event.get("isBase64Encoded", False):
            import base64
            body = base64.b64decode(body).decode("utf-8")
        
        # Parse JSON data
        # stats_data = json.loads(content)
        stats_data = json.loads(body)
        
        # Add timestamp and store data in DynamoDB
        for item in stats_data["stats"]:
            item["timestamp"] = datetime.utcnow().isoformat()
            # Put item into DynamoDB table
            item["id"] = str(uuid.uuid4())
            table.put_item(Item=item)
        
        return {
            "statusCode": 200,
            "body": "Data inserted into DynamoDB successfully"
        }
        
    except Exception as e:
        return {
            "statusCode": 500,
            "body": str(e)
        }
