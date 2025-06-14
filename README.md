# Docker Compose System Design Learning Lab

Welcome to the Docker Compose System Design Learning Lab! This repository is designed to help you learn system design concepts through hands-on projects using Docker Compose. Each project demonstrates different architectural patterns and system design principles in a practical, containerized environment.

## 🎯 Learning Path

1. **Basic Concepts** → Static Blog (Simple static website)
2. **Database Integration** → Blog App (Relational database)
3. **NoSQL & Microservices** → Profile App (Document database)
4. **Caching & Performance** → URL Shortener (In-memory database)
5. **Event-Driven Architecture** → Kafka Simulator (Message broker)

## 📚 System Design Fundamentals

### Key Concepts Covered

- **Scalability**: Horizontal vs Vertical scaling
- **Availability**: High availability patterns
- **Consistency**: CAP theorem in practice
- **Load Balancing**: Using Nginx as reverse proxy
- **Caching**: Redis for performance optimization
- **Message Queues**: Event-driven architecture with Kafka
- **Database Types**: SQL vs NoSQL in practice
- **Microservices**: Service decomposition and communication

## 🏗️ Project Architecture Overview

### 1. Static Blog (static_blog.sh)
**Purpose**: Simple static website hosting solution using Nginx and Docker.

**Key Features**:
- Static file serving with Nginx
- HTML/CSS-based responsive design
- Basic caching configuration
- Docker containerization

**Technical Details**:
- Nginx server configuration
- Static file structure (index.html, about.html, style.css)
- Docker volume management
- Port mapping (8080:80)

**Architecture**:
```
+----------------+     HTTP/HTTPS    +----------------+
| Client Browser | <---------------> | Nginx Server   |
+----------------+    Port: 8080     +----------------+
                                    | - nginx:1.21    |
                                    | - worker_procs: 4|
                                    +----------------+
                                          |
                                          | Serve Static Content
                                          v
                                  +----------------+
                                  | Static Files   |
                                  | - index.html   | (Main page)
                                  | - about.html   | (About page)
                                  | - style.css    | (Styling)
                                  | Volume: /usr/share/nginx/html
                                  +----------------+
```

**Learning Outcomes**:
- Basic web server concepts
- Static content serving
- Docker container basics
- Nginx configuration

### 2. Blog App (blog-app.sh)
**Purpose**: Full-stack blog application with Node.js and MongoDB.

**Key Features**:
- Frontend with HTML/CSS/JavaScript
- Backend REST API with Express.js
- MongoDB database integration
- CRUD operations for blog posts
- Mongo Express for database management
- Portainer for container monitoring

**Technical Details**:
- Frontend: Static file serving with http-server
- Backend: Express.js with MongoDB
- Database: MongoDB with persistent storage
- Port mappings:
  - Frontend: 8080:8080
  - Backend: 3000:3000
  - MongoDB: 27017:27017
  - Mongo Express: 8081:8081
  - Portainer: 9000:9000

**Architecture**:
```
+----------------+     HTTP/HTTPS    +----------------+
| Client Browser | <---------------> | Frontend       |
+----------------+    Port: 8080     | (http-server)  |
                                    | - Node.js 16.x |
                                    +----------------+
                                          |
                                          | REST API Calls
                                          v
                                  +----------------+
                                  | Backend        |
                                  | (Express.js)   |
                                  | - Node.js 16.x |
                                  | - Port: 3000   |
                                  | - CRUD ops     |
                                  +----------------+
                                          |
                    +---------------------+---------------------+
                    |                     |                     |
                    v                     v                     v
            +-------------+      +----------------+      +-------------+
            | MongoDB     |      | Mongo Express  |      | Portainer   |
            | (Database)  |      | (DB Admin UI)  |      | (Monitoring)|
            | Port: 27017|      | Port: 8081     |      | Port: 9000  |
            | v4.4.x     |      | v0.54.0        |      | v2.9.3      |
            +-------------+      +----------------+      +-------------+
```

**Learning Outcomes**:
- Full-stack development
- REST API design
- MongoDB integration
- Docker Compose networking
- Container monitoring

### 3. Profile App (profile_app.sh)
**Purpose**: Profile management application with real-time preview.

**Key Features**:
- Real-time profile preview
- Form validation
- MongoDB data persistence
- Mongo Express for database management
- Single profile management (upsert functionality)

**Technical Details**:
- Frontend: HTML/CSS/JavaScript with real-time updates
- Backend: Express.js with MongoDB
- Database: MongoDB with schema validation
- Port mappings:
  - Frontend: 8085:8080
  - Backend: 3000:3000
  - MongoDB: 27017:27017
  - Mongo Express: 8081:8081

**Architecture**:
```
+----------------+  Real-time Updates  +----------------+
| Client Browser | <-----------------> | Frontend       |
+----------------+    Port: 8085      | (http-server)  |
                                      | - Node.js 16.x |
                                      +----------------+
                                              |
                                              | REST API Calls
                                              v
                                      +----------------+
                                      | Backend        |
                                      | (Express.js)   |
                                      | - Node.js 16.x |
                                      | - Port: 3000   |
                                      | - Profile CRUD |
                                      +----------------+
                                              |
                    +-------------------------+-------------------------+
                    |                         |                         |
                    v                         v                         v
            +-------------+          +----------------+          +-------------+
            | MongoDB     |          | Mongo Express  |          | Validation  |
            | (Database)  |          | (DB Admin UI)  |          | Service     |
            | Port: 27017|          | Port: 8081     |          | Port: 3001  |
            | v4.4.x     |          | v0.54.0        |          | (JWT Auth)  |
            +-------------+          +----------------+          +-------------+
```

**Learning Outcomes**:
- Real-time form updates
- MongoDB schema design
- Data validation
- Docker Compose service dependencies

### 4. URL Shortener (url-shortener.sh)
**Purpose**: URL shortening service with monitoring and analytics.

**Key Features**:
- FastAPI backend
- Redis caching
- PostgreSQL database
- Prometheus metrics
- Grafana dashboards
- Redis Commander for cache management
- pgAdmin for database management
- Logging configuration

**Technical Details**:
- Backend: FastAPI with SQLAlchemy
- Cache: Redis with health checks
- Database: PostgreSQL with persistent storage
- Monitoring: Prometheus and Grafana
- Port mappings:
  - Backend: 8000:8000
  - Redis: 6379:6379
  - PostgreSQL: 5432:5432
  - Prometheus: 9090:9090
  - Grafana: 3000:3000
  - Redis Commander: 8081:8081
  - pgAdmin: 8080:80

**Architecture**:
```
+----------------+     HTTP/HTTPS    +----------------+
| Client Browser | <---------------> | Backend        |
+----------------+    Port: 8000     | (FastAPI)      |
                                    | - Python 3.9+  |
                                    | - Port: 8000   |
                                    | - URL Shortener|
                                    +----------------+
                                          |
                    +---------------------+---------------------+
                    |                     |                     |
                    v                     v                     v
            +-------------+      +----------------+      +-------------+
            | Redis Cache |      | PostgreSQL     |      | Prometheus  |
            | (URL Cache) |      | (URL Storage)  |      | (Metrics)   |
            | Port: 6379  |      | Port: 5432     |      | Port: 9090  |
            | v6.2.x      |      | v13.x          |      | v2.30.x     |
            +-------------+      +----------------+      +-------------+
                    |                     |                     |
                    v                     v                     v
            +-------------+      +----------------+      +-------------+
            | Redis       |      | pgAdmin       |      | Grafana     |
            | Commander   |      | (DB Admin UI) |      | (Dashboard) |
            | Port: 8081  |      | Port: 8080    |      | Port: 3000  |
            | v1.8.0      |      | v6.0          |      | v8.2.x      |
            +-------------+      +----------------+      +-------------+
```

**Learning Outcomes**:
- FastAPI development
- Redis caching strategies
- PostgreSQL integration
- Monitoring and metrics
- Docker Compose health checks
- Logging best practices

### 5. Kafka Simulator (kafka-simulator.sh)
**Purpose**: Real-time order processing system with Kafka.

**Key Features**:
- Kafka producer for order generation
- Multiple consumer groups:
  - Order validation
  - Order fulfillment
  - Notifications
- Zookeeper for Kafka management
- Topic partitioning (3 partitions)

**Technical Details**:
- Kafka cluster setup
- Python-based producer and consumers
- Topic configuration
- Port mappings:
  - Zookeeper: 2181:2181
  - Kafka: 9092:9092

**Architecture**:
```
+----------------+  Publish Orders  +----------------+
| Order Producer | ---------------> | Kafka Broker   |
+----------------+                  | (Message Queue)|
| - Python 3.9+  |                  | - Port: 9092   |
| - Port: 9092   |                  | - v2.8.x       |
+----------------+                  +----------------+
                                          |
                    +---------------------+---------------------+
                    |                     |                     |
                    v                     v                     v
            +-------------+      +----------------+      +-------------+
            | Order       |      | Order         |      | Notification|
            | Validator   |      | Fulfiller     |      | Service     |
            | (Validate)  |      | (Process)     |      | (Notify)    |
            | - Python    |      | - Python      |      | - Python    |
            | - Port: 3002|      | - Port: 3003  |      | - Port: 3004|
            +-------------+      +----------------+      +-------------+
                    ^                     ^                     ^
                    |                     |                     |
                    +---------------------+---------------------+
                                          |
                                  +----------------+
                                  | Zookeeper      |
                                  | (Kafka Manager)|
                                  | - Port: 2181   |
                                  | - v3.7.x       |
                                  +----------------+
```

**Learning Outcomes**:
- Kafka message queuing
- Consumer groups
- Topic partitioning
- Event-driven architecture
- Docker Compose service orchestration

## 🚀 Getting Started

### Prerequisites
- Docker Engine (version 20.10.0 or later)
- Docker Compose (version 2.0.0 or later)
- Git (for cloning the repository)
- Basic understanding of Docker concepts

### Deployment Instructions

#### 1. Static Blog Deployment
```bash
# Clone the repository
git clone <repository-url>
cd Docker_compose

# Make the script executable and run it
chmod +x static_blog.sh
./static_blog.sh

# The script will:
# - Create necessary directories
# - Generate static files
# - Set up Nginx configuration
# - Create Docker Compose file
# - Start the service

# Verify deployment
curl http://localhost:8080

# Check logs
docker-compose logs -f

# Stop the service
docker-compose down
```

**Troubleshooting**:
- If port 8080 is already in use, modify the port in `docker-compose.yml`
- Check Nginx logs: `docker-compose logs nginx`
- Verify static files: `docker-compose exec nginx ls /usr/share/nginx/html`

#### 2. Blog App Deployment
```bash
# Clone the repository
git clone <repository-url>
cd Docker_compose

# Make the script executable and run it
chmod +x blog-app.sh
./blog-app.sh

# The script will:
# - Create frontend and backend directories
# - Generate necessary files
# - Set up MongoDB configuration
# - Create Docker Compose file
# - Start all services

# Verify services
curl http://localhost:8080  # Frontend
curl http://localhost:3000/api/posts  # Backend API
http://localhost:8081  # Mongo Express (browser)
http://localhost:9000  # Portainer (browser)

# Check logs
docker-compose logs -f [service-name]  # e.g., backend, frontend, mongo

# Stop all services
docker-compose down
```

**Troubleshooting**:
- MongoDB connection issues: Check `docker-compose logs mongo`
- Frontend not loading: Verify `http-server` is running
- API errors: Check backend logs
- Database persistence: Verify volume mounting

#### 3. Profile App Deployment
```bash
# Clone the repository
git clone <repository-url>
cd Docker_compose

# Make the script executable and run it
chmod +x profile_app.sh
./profile_app.sh

# The script will:
# - Create frontend and backend directories
# - Generate necessary files
# - Set up MongoDB configuration
# - Create Docker Compose file
# - Start all services

# Verify services
curl http://localhost:8085  # Frontend
curl http://localhost:3000/api/profile  # Backend API
http://localhost:8081  # Mongo Express (browser)

# Monitor logs
docker-compose logs -f [service-name]

# Stop services
docker-compose down
```

**Troubleshooting**:
- Profile updates not saving: Check MongoDB connection
- Frontend preview not working: Verify JavaScript console
- CORS issues: Check backend CORS configuration

#### 4. URL Shortener Deployment
```bash
# Clone the repository
git clone <repository-url>
cd Docker_compose

# Make the script executable and run it
chmod +x url-shortener.sh
./url-shortener.sh

# The script will:
# - Create necessary directories
# - Generate backend code
# - Set up PostgreSQL and Redis configurations
# - Configure monitoring tools
# - Create Docker Compose file
# - Start all services

# Verify services
curl http://localhost:8000/health  # Backend health check
http://localhost:3000  # Grafana (browser)
http://localhost:9090  # Prometheus (browser)
http://localhost:8081  # Redis Commander (browser)
http://localhost:8080  # pgAdmin (browser)

# Check service health
docker-compose ps

# Monitor logs
docker-compose logs -f [service-name]

# Stop all services
docker-compose down
```

**Troubleshooting**:
- Database connection: Check PostgreSQL logs
- Redis connection: Verify Redis health check
- Monitoring setup: Check Prometheus targets
- Grafana dashboards: Verify data source configuration

#### 5. Kafka Simulator Deployment
```bash
# Clone the repository
git clone <repository-url>
cd Docker_compose

# Make the script executable and run it
chmod +x kafka-simulator.sh
./kafka-simulator.sh

# The script will:
# - Create necessary directories
# - Generate producer and consumer code
# - Set up Kafka and Zookeeper configurations
# - Create Docker Compose file
# - Start all services

# Verify services
# Check Kafka topic
docker-compose exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Monitor consumer groups
docker-compose exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --list

# Check logs
docker-compose logs -f [service-name]

# Stop all services
docker-compose down
```

**Troubleshooting**:
- Kafka connection: Check Zookeeper logs
- Topic creation: Verify topic exists
- Consumer issues: Check consumer group status
- Producer errors: Monitor producer logs

### Common Deployment Issues

1. **Port Conflicts**
   - Check if ports are already in use: `lsof -i :<port>`
   - Modify port mappings in `docker-compose.yml`
   - Use different ports for each project

2. **Container Networking**
   - Verify service dependencies in `docker-compose.yml`
   - Check container names and network aliases
   - Use `docker network ls` to inspect networks

3. **Volume Mounting**
   - Check volume permissions
   - Verify volume paths in `docker-compose.yml`
   - Use `docker volume ls` to list volumes

4. **Service Health**
   - Check service health: `docker-compose ps`
   - Monitor logs: `docker-compose logs -f`
   - Verify environment variables

5. **Resource Limits**
   - Monitor container resources: `docker stats`
   - Adjust resource limits in `docker-compose.yml`
   - Check system resource usage

### Best Practices

1. **Before Deployment**
   - Review `docker-compose.yml` configuration
   - Check environment variables
   - Verify directory structure
   - Ensure ports are available

2. **During Deployment**
   - Monitor build process
   - Check service startup order
   - Verify service health
   - Test basic functionality

3. **After Deployment**
   - Monitor logs for errors
   - Test all features
   - Verify data persistence
   - Check monitoring tools

4. **Maintenance**
   - Regular log rotation
   - Database backups
   - Volume cleanup
   - Container updates

## 🔧 Common Operations

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f [service]

# Scale services
docker-compose up -d --scale [service]=3

# Clean up
docker-compose down -v
```

### Monitoring & Debugging

```bash
# View container status
docker ps

# Check service logs
docker-compose logs -f

# Inspect network
docker network inspect [network_name]
```

## 📈 Learning Progression

1. **Beginner Level**
   - Start with static_blog.sh
   - Understand basic container concepts
   - Learn about web servers

2. **Intermediate Level**
   - Move to blog-app.sh
   - Explore database integration
   - Understand three-tier architecture

3. **Advanced Level**
   - Try profile_app.sh
   - Learn microservices patterns
   - Explore NoSQL databases

4. **Expert Level**
   - Implement url-shortener.sh
   - Master caching strategies
   - Understand performance optimization

5. **System Design Mastery**
   - Deploy kafka-simulator.sh
   - Learn event-driven architecture
   - Understand distributed systems

## 🤝 Contributing

Feel free to contribute to this learning resource by:
- Adding new projects
- Improving documentation
- Fixing bugs
- Adding more system design patterns

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [System Design Primer](https://github.com/donnemartin/system-design-primer)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

