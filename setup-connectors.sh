#!/bin/bash

KAFKA_CONNECT_URL="http://kafka-connect:8083"
KAFKA_SCHEMA_REGISTRY_URL="http://schema-registry:8081"
KSQL_URL="http://ksql-server:8088"

create_schema() {
    echo "Criando schema..."
    curl -X POST -H "Content-Type: application/json" \
        --data '{
            "schema": "{\"type\":\"record\",\"name\":\"UserEvent\",\"namespace\":\"com.example\",\"fields\":[{\"name\":\"user_id\",\"type\":\"int\"},{\"name\":\"event_type\",\"type\":\"string\"},{\"name\":\"timestamp\",\"type\":\"string\"},{\"name\":\"user_type\",\"type\":\"string\"},{\"name\":\"location\",\"type\":\"string\"}]}"
        }' \
        "$KAFKA_SCHEMA_REGISTRY_URL/subjects/user_events-value/versions"
}

create_connector() {
    echo "Criando conector..."
    curl -X POST -H "Content-Type: application/json" \
        -d '{
            "name": "s3-sink-connector",
            "config": {
                "connector.class": "io.confluent.connect.s3.S3SinkConnector",
                "tasks.max": "1", 
                "topics": "user_events_avro",  
                "s3.bucket.name": "analytics-cold-store",
                "s3.region": "us-east-1",
                "storage.class": "io.confluent.connect.s3.storage.S3Storage",
                "format.class": "io.confluent.connect.s3.format.parquet.ParquetFormat",
                "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
                "flush.size": "50",
                "value.converter": "io.confluent.connect.avro.AvroConverter",
                "key.converter.schemas.enable": "false", 
                "value.converter.schemas.enable": "true",
                "value.converter.schema.registry.url": "http://schema-registry:8081",
                "value.converter.registry.name": "user_events-value",
                "parquet.codec": "snappy"
            }
        }' \
        "$KAFKA_CONNECT_URL/connectors"
}

run_ksql() {
    echo "Executando KSQL..."

    curl -X POST -H "Content-Type: application/json" \
        --data "{
            \"ksql\": \"CREATE STREAM source_user_events (user_id INT, event_type STRING, timestamp STRING, user_type STRING, location STRING) WITH (KAFKA_TOPIC='user_events', VALUE_FORMAT='JSON');\"
        }" \
        "$KSQL_URL/ksql"

    curl -X POST -H "Content-Type: application/json" \
        --data "{
            \"ksql\": \"CREATE STREAM target_user_events_avro WITH (KAFKA_TOPIC='user_events_avro', VALUE_FORMAT='AVRO') AS SELECT * FROM source_user_events;\"
        }" \
        "$KSQL_URL/ksql"
}

create_schema
run_ksql
create_connector

