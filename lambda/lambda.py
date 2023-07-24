import boto3
from PIL import Image
from io import BytesIO
import os, json

s3 = boto3.client('s3')

source_bucket = os.environ['source_bucket']
destination_bucket = os.environ['destination_bucket']

def create_thumbnail(image):
    # Open the image using PIL
    img = Image.open(image)
    
    # Create a thumbnail with a maximum size of 128x128
    img.thumbnail((128, 128))
    
    # Save the thumbnail to a BytesIO object
    thumbnail_buffer = BytesIO()
    img.save(thumbnail_buffer, format='JPEG')
    thumbnail_buffer.seek(0)
    
    return thumbnail_buffer

def lambda_handler(event, context):
    for record in event['Records']:
        # Extract the S3 object key from the SQS message
        records = json.loads(record['body'])["Records"]
        for subrecord in records:
            s3_key = subrecord["s3"]["object"]["key"]
        
            # Download the image from the source S3 bucket
            response = s3.get_object(Bucket=source_bucket, Key=s3_key)
            image_data = response['Body'].read()
            
            # Create a thumbnail of the image
            thumbnail = create_thumbnail(BytesIO(image_data))
            
            # Upload the thumbnail to the destination S3 bucket
            s3.put_object(Body=thumbnail, Bucket=destination_bucket, Key=f'thumbnails/{s3_key}')
            
            print(f"Thumbnail created for {s3_key}")
