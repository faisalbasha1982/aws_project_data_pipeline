
# subscription_lambda.py
import json
import boto3
import os

def lambda_handler(event, context):
    sns = boto3.client('sns')
    topic_arn = os.environ['TOPIC_ARN']

    try:
        body = json.loads(event['body'])
        email = body['email']
    except (KeyError, json.JSONDecodeError):
        return {
            "statusCode": 400,
            "headers": cors_headers(),
            "body": json.dumps({"error": "Invalid input"})
        }

    response = sns.subscribe(
        TopicArn=topic_arn,
        Protocol='email',
        Endpoint=email
    )

    return {
        "statusCode": 200,
        "headers": cors_headers(),
        "body": json.dumps({"message": "Subscription request sent. Please check your email."})
    }

def cors_headers():
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST"
    }

