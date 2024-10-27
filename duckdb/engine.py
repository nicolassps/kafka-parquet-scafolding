import duckdb
import boto3
import pandas as pd

bucket_name = 'analytics-cold-store'
prefix = 'topics/user_events_avro/partition=0/'

s3 = boto3.client('s3')

response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
parquet_files = [content['Key'] for content in response.get('Contents', []) if content['Key'].endswith('.parquet')]

con = duckdb.connect()

con.execute("CREATE TABLE user_events AS SELECT * FROM read_parquet('s3://{}/{}')".format(bucket_name, parquet_files[0]))

for file in parquet_files:
    con.execute("INSERT INTO user_events SELECT * FROM read_parquet('s3://{}/{}')".format(bucket_name, file))

result1 = con.execute("SELECT COUNT(*) FROM user_events").fetchall()
print("Total de eventos:", result1)

result2 = con.execute("SELECT user_type, COUNT(*) FROM user_events GROUP BY user_type").fetchall()
print("Contagem de eventos por tipo de usuário:", result2)

result3 = con.execute("SELECT event_type, COUNT(*) FROM user_events WHERE timestamp >= '2023-10-27' GROUP BY event_type").fetchall()
print("Contagem de eventos por tipo após uma data específica:", result3)

con.close()
