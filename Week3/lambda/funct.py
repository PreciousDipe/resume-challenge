import boto3
import json

table_name = 'views_table'
partition_key_name = 'id'

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)

    # Specify the partition key value
    partition_key_value = '1'

    try:
        # Increment views using a single update_item call
        response = table.update_item(
            Key={
                partition_key_name: partition_key_value
            },
            UpdateExpression="SET #views = if_not_exists(#views, :zero) + :val",
            ExpressionAttributeNames={
                '#views': 'views'
            },
            ExpressionAttributeValues={
                ':zero': 0,  # Set 'zero' as an integer
                ':val': 1    # Set 'val' as an integer
            },
            ReturnValues="UPDATED_NEW"
        )

        # Get the updated item data
        updated_item = response['Attributes']

        # Return the updated item data as JSON
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
            },
            'body': json.dumps({'views': int(updated_item['views'])})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
