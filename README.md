# Docker Compose System Design Learning Lab

Welcome to the Docker Compose System Design Learning Lab! This repository is designed to help you learn system design concepts through hands-on projects using Docker Compose. Each project demonstrates different architectural patterns and system design principles in a practical, containerized environment.

## 🎯 Learning Path

1. **Basic Concepts** → Static Blog (Simple static website)
2. **Database Integration** → Blog App (Relational database)
3. **NoSQL & Microservices** → Profile App (Document database)
4. **Caching & Performance** → URL Shortener (In-memory database)

## 📚 System Design Fundamentals

### Key Concepts Covered

- **Scalability**: Horizontal vs Vertical scaling
- **Availability**: High availability patterns
- **Consistency**: CAP theorem in practice
- **Load Balancing**: Using Nginx as reverse proxy
- **Caching**: Redis for performance optimization
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

## 🚀 Getting Started

### Prerequisites
- Docker Engine (version 20.10.0 or later)
- Docker Compose (version 2.0.0 or later)
- Git (for cloning the repository)
- Basic understanding of Docker concepts

### Quick Start

```bash
# Clone the repository
git clone https://github.com/toasobi-lab/Docker_compose.git
cd Docker_compose

# Choose a project to start with (recommended order):
# 1. Static Blog (beginner)
chmod +x static_blog.sh && ./static_blog.sh

# 2. Blog App (intermediate)
chmod +x blog-app.sh && ./blog-app.sh

# 3. Profile App (advanced)
chmod +x profile_app.sh && ./profile_app.sh

# 4. URL Shortener (expert)
chmod +x url-shortener.sh && ./url-shortener.sh
```

### Deployment Instructions

#### 1. Static Blog Deployment
```bash
# Clone the repository
git clone https://github.com/toasobi-lab/Docker_compose.git
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
git clone https://github.com/toasobi-lab/Docker_compose.git
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
git clone https://github.com/toasobi-lab/Docker_compose.git
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
git clone https://github.com/toasobi-lab/Docker_compose.git
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

## 🛠️ Project Structure

```
Docker_compose/
├── README.md                 # This file
├── static_blog.sh           # Static blog deployment script
├── blog-app.sh              # Blog app deployment script
├── profile_app.sh           # Profile app deployment script
├── url-shortener.sh         # URL shortener deployment script
└── docker_command.sh        # Common Docker commands reference
```

## 🎓 Learning Objectives

By completing all projects in this lab, you will gain hands-on experience with:

- **Container Orchestration**: Docker Compose for multi-service applications
- **Web Technologies**: HTML, CSS, JavaScript, Node.js, Python FastAPI
- **Databases**: MongoDB (NoSQL) and PostgreSQL (SQL)
- **Caching**: Redis for performance optimization
- **Monitoring**: Prometheus and Grafana for observability
- **Load Balancing**: Nginx as reverse proxy
- **Microservices**: Service decomposition and communication patterns
- **DevOps Practices**: Containerization, orchestration, and monitoring

## 🤝 Contributing

We welcome contributions to improve this learning resource! Here's how you can help:

### Ways to Contribute

- **Add New Projects**: Create new system design patterns and architectures
- **Improve Documentation**: Enhance README, add tutorials, or fix typos
- **Bug Fixes**: Report and fix issues in existing projects
- **Feature Requests**: Suggest new features or improvements
- **Code Reviews**: Review pull requests and provide feedback

### Contributing Guidelines

1. **Fork the Repository**: Create your own fork of the project
2. **Create a Feature Branch**: Make your changes in a new branch
3. **Follow Coding Standards**: Maintain consistent code style and documentation
4. **Test Your Changes**: Ensure all scripts work correctly
5. **Submit a Pull Request**: Describe your changes clearly

### Development Setup

```bash
# Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/Docker_compose.git
cd Docker_compose

# Create a new branch for your feature
git checkout -b feature/your-feature-name

# Make your changes and test them
# ...

# Commit and push your changes
git add .
git commit -m "Add: description of your changes"
git push origin feature/your-feature-name
```

## 📚 Additional Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

### Learning Resources
- [System Design Primer](https://github.com/donnemartin/system-design-primer)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Microservices Patterns](https://microservices.io/patterns/)
- [CAP Theorem Explained](https://en.wikipedia.org/wiki/CAP_theorem)

### Community & Support
- [Docker Community](https://www.docker.com/community/)
- [Stack Overflow - Docker](https://stackoverflow.com/questions/tagged/docker)
- [GitHub Discussions](https://github.com/toasobi-lab/Docker_compose/discussions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to the Docker community for excellent tooling
- Inspired by various system design resources and tutorials
- Built for educational purposes to help developers learn system design concepts

## 📞 Contact

- **Repository**: [https://github.com/toasobi-lab/Docker_compose](https://github.com/toasobi-lab/Docker_compose)
- **Issues**: [GitHub Issues](https://github.com/toasobi-lab/Docker_compose/issues)
- **Discussions**: [GitHub Discussions](https://github.com/toasobi-lab/Docker_compose/discussions)

---

**Happy Learning! 🚀**

*This repository is designed to help you master system design concepts through practical, hands-on experience with Docker Compose. Start with the static blog and work your way up to the advanced URL shortener project.*

