# Docker\_compose

This repository contains a collection of small local projects designed to facilitate learning in system design using Docker Compose. Each project is encapsulated in a shell script, providing a hands-on approach to understanding various system components and their interactions.

## Table of Contents

- [Projects Overview](#projects-overview)
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Usage](#usage)

## Projects Overview

The repository includes the following projects, each designed to help you learn specific aspects of system design, containerization, and microservices using Docker Compose.

### **1. blog-app.sh**

- **Tech Stack:** Docker, Nginx, PostgreSQL, Flask (Python)
- **Learning Objectives:**
  - Setting up a full-stack web application with Docker Compose
  - Configuring Nginx as a reverse proxy
  - Connecting a backend service with a database in a containerized environment

### **2. docker\_command.sh**

- **Tech Stack:** Docker
- **Learning Objectives:**
  - Understanding common Docker commands
  - Managing containers, images, volumes, and networks
  - Learning best practices for running and troubleshooting Docker containers

### **3. kafka-simulator.sh**

- **Tech Stack:** Apache Kafka, Zookeeper, Docker
- **Learning Objectives:**
  - Setting up a Kafka cluster using Docker Compose
  - Understanding how Kafka manages messaging between producers and consumers
  - Exploring real-time event streaming and message brokering

### **4. profile\_app.sh**

- **Tech Stack:** Node.js, Express, MongoDB, Docker
- **Learning Objectives:**
  - Building a microservices-based profile management application
  - Using MongoDB as a document-based NoSQL database
  - Handling API requests and managing user data in a containerized setup

### **5. static\_blog.sh**

- **Tech Stack:** Nginx, Jekyll (or Hugo), Docker
- **Learning Objectives:**
  - Hosting a static website with Nginx in a containerized environment
  - Automating static site generation using Jekyll or Hugo
  - Deploying lightweight websites using Docker

### **6. url-shortener.sh**

- **Tech Stack:** Python (Flask), Redis, Docker
- **Learning Objectives:**
  - Building a simple URL shortener with Flask
  - Using Redis as an in-memory database for quick lookups
  - Understanding how microservices interact in a lightweight environment

Each project provides hands-on experience in working with containerized applications, improving your understanding of system architecture, and deploying scalable services using Docker Compose.

## Getting Started

To get started with any of these projects, clone the repository to your local machine:

```bash
git clone https://github.com/toasobi-lab/Docker_compose.git
cd Docker_compose
```

## Prerequisites

Before running the projects, ensure you have the following installed on your system:

- [Docker](https://docs.docker.com/get-docker/) - Required for containerization
- [Docker Compose](https://docs.docker.com/compose/install/) - Required for managing multi-container applications
- A Unix-based shell (Linux/macOS) or Git Bash (Windows) to execute shell scripts

You can verify your installation with:

```bash
docker --version
docker-compose --version
```

If Docker is not running, start the Docker service before proceeding.

## Usage

To execute any of the projects, navigate to the respective project directory, set the permission for the shell script, and run it.

```bash
chmod +x project_name.sh
./project_name.sh
```

For example, to run the `blog-app.sh` project:

```bash
chmod +x blog-app.sh
./blog-app.sh
```

### Common Docker Compose Commands

- **Start all services:**
  ```bash
  docker-compose up -d
  ```
- **Stop all services:**
  ```bash
  docker-compose down
  ```
- **View running containers:**
  ```bash
  docker ps
  ```
- **View logs of a specific service:**
  ```bash
  docker-compose logs -f service_name
  ```
- **Restart a specific service:**
  ```bash
  docker-compose restart service_name
  ```

These commands help manage and troubleshoot the running projects effectively.

