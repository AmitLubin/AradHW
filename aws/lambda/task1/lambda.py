import json
import requests

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        word = body.get('word')

        if not word:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'word' in request body"})
            }

        # Send POST request to your Flask app
        response = requests.post(
            "http://amit.aws.cts.care:3000",
            data={'word': word},
            timeout=3
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Word sent successfully",
                "status": response.status_code,
                "response_snippet": response.text[:200]
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
