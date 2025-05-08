
import boto3
import csv
import io
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    response = s3.get_object(Bucket=bucket, Key=key)
    lines = response['Body'].read().decode('utf-8').splitlines()
    reader = csv.DictReader(lines)

    cleaned_data = [row for row in reader if all(row.values())]

    output_key = key.replace("raw", "processed")
    output_bucket = os.environ.get("PROCESSED_BUCKET")

    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=reader.fieldnames)
    writer.writeheader()
    writer.writerows(cleaned_data)
    s3.put_object(Bucket=output_bucket, Key=output_key, Body=output.getvalue())
