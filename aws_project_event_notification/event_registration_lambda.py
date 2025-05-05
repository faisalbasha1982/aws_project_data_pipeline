# event_registration_lambda.py
import json
import boto3
import os

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = os.environ['BUCKET_NAME']
    key = 'events.json'

    try:
        body = json.loads(event['body'])
        new_event = {
            "name": body['name'],
            "description": body['description']
        }
    except (KeyError, json.JSONDecodeError):
        return {
            "statusCode": 400,
            "headers": cors_headers(),
            "body": json.dumps({"error": "Invalid input"})
        }

    try:
        response = s3.get_object(Bucket=bucket_name, Key=key)
        events = json.loads(response['Body'].read().decode('utf-8'))
    except s3.exceptions.NoSuchKey:
        events = []

    events.append(new_event)
    s3.put_object(Bucket=bucket_name, Key=key, Body=json.dumps(events), ContentType='application/json')

    return {
        "statusCode": 200,
        "headers": cors_headers(),
        "body": json.dumps({"message": "Event added"})
    }

def cors_headers():
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
    }

