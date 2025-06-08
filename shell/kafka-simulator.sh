#!/bin/bash

# Set the base directory
BASE_DIR=$(pwd)/real-time-order-processing

# Create project directories
mkdir -p $BASE_DIR/kafka
mkdir -p $BASE_DIR/producer
mkdir -p $BASE_DIR/consumers/order_validation
mkdir -p $BASE_DIR/consumers/order_fulfillment
mkdir -p $BASE_DIR/consumers/notifications

# Create Kafka docker-compose.yml
cat << 'EOF' > $BASE_DIR/kafka/docker-compose.yml
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000

  kafka:
    image: confluentinc/cp-kafka:latest
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    depends_on:
      - zookeeper
EOF

# Create Kafka topic setup script
cat << 'EOF' > $BASE_DIR/kafka/create-topics.sh
#!/bin/bash

# Find the Kafka container name
KAFKA_CONTAINER=$(docker ps --filter "name=kafka" --format "{{.Names}}")

if [ -z "$KAFKA_CONTAINER" ]; then
  echo "Error: Kafka container not found. Please ensure the Kafka service is running."
  exit 1
fi

# Create the Kafka topic
docker exec -it "$KAFKA_CONTAINER" kafka-topics --create --topic order_topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

echo "Kafka topic 'order_topic' created successfully."
EOF
chmod +x $BASE_DIR/kafka/create-topics.sh

# Create producer files
cat << 'EOF' > $BASE_DIR/producer/producer.py
from kafka import KafkaProducer
import json
import time
import random

def generate_order():
    products = ['Laptop', 'Phone', 'Headphones', 'Monitor']
    return {
        'order_id': random.randint(1000, 9999),
        'product': random.choice(products),
        'quantity': random.randint(1, 5)
    }

producer = KafkaProducer(
    bootstrap_servers='kafka:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

while True:
    order = generate_order()
    producer.send('order_topic', order)
    print(f"Order sent: {order}")
    time.sleep(2)
EOF

cat << 'EOF' > $BASE_DIR/producer/requirements.txt
kafka-python==2.0.2
EOF

cat << 'EOF' > $BASE_DIR/producer/Dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY producer.py .
CMD ["python", "producer.py"]
EOF

# Create consumer files for order_validation
cat << 'EOF' > $BASE_DIR/consumers/order_validation/consumer.py
from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'order_topic',
    bootstrap_servers='kafka:9092',
    group_id='validation_group',
    value_deserializer=lambda v: json.loads(v.decode('utf-8'))
)

for message in consumer:
    order = message.value
    print(f"Order validation: {order}")
EOF

cat << 'EOF' > $BASE_DIR/consumers/order_validation/requirements.txt
kafka-python==2.0.2
EOF

cat << 'EOF' > $BASE_DIR/consumers/order_validation/Dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY consumer.py .
CMD ["python", "consumer.py"]
EOF

# Create consumer files for order_fulfillment
cat << 'EOF' > $BASE_DIR/consumers/order_fulfillment/consumer.py
from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'order_topic',
    bootstrap_servers='kafka:9092',
    group_id='fulfillment_group',
    value_deserializer=lambda v: json.loads(v.decode('utf-8'))
)

for message in consumer:
    order = message.value
    print(f"Order fulfillment: {order}")
EOF

cat << 'EOF' > $BASE_DIR/consumers/order_fulfillment/requirements.txt
kafka-python==2.0.2
EOF

cat << 'EOF' > $BASE_DIR/consumers/order_fulfillment/Dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY consumer.py .
CMD ["python", "consumer.py"]
EOF

# Create consumer files for notifications
cat << 'EOF' > $BASE_DIR/consumers/notifications/consumer.py
from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'order_topic',
    bootstrap_servers='kafka:9092',
    group_id='notifications_group',
    value_deserializer=lambda v: json.loads(v.decode('utf-8'))
)

for message in consumer:
    order = message.value
    print(f"Notification sent: {order}")
EOF

cat << 'EOF' > $BASE_DIR/consumers/notifications/requirements.txt
kafka-python==2.0.2
EOF

cat << 'EOF' > $BASE_DIR/consumers/notifications/Dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY consumer.py .
CMD ["python", "consumer.py"]
EOF

# Create README.md
cat << 'EOF' > $BASE_DIR/README.md
# Real-Time Order Processing System Using Kafka and Docker Compose

## Overview
This project demonstrates a real-time order processing system using Kafka. It includes:
- Kafka Producer to simulate order data
- Kafka Consumers for validation, fulfillment, and notifications
- Docker Compose for orchestrating Kafka and all services

## Project Structure
- **kafka**: Kafka and Zookeeper setup
- **producer**: Sends simulated orders to `order_topic`
- **consumers**:
  - `order_validation`: Validates stock availability
  - `order_fulfillment`: Simulates order fulfillment
  - `notifications`: Sends notifications to customers

## How to Run
1. Start Kafka and Zookeeper:
   ```bash
   cd kafka
   docker-compose up -d
