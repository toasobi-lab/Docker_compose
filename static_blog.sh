#!/bin/bash

# Set the base directory
BASE_DIR=$(pwd)/static-blog

# Create directories
mkdir -p "$BASE_DIR/static/assets"
mkdir -p "$BASE_DIR/nginx/static"

# Create static files (index.html, about.html, style.css)
cat << 'EOF' > "$BASE_DIR/static/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Static Blog</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Welcome to My Static Blog</h1>
        <nav>
            <a href="index.html">Home</a>
            <a href="about.html">About</a>
        </nav>
    </header>
    <main>
        <h2>Latest Posts</h2>
        <p>This is a simple static blog platform powered by Nginx and Docker.</p>
    </main>
    <footer>
        <p>&copy; 2025 My Static Blog. All rights reserved.</p>
    </footer>
</body>
</html>
EOF

cat << 'EOF' > "$BASE_DIR/static/about.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - My Static Blog</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>About Me</h1>
        <nav>
            <a href="index.html">Home</a>
            <a href="about.html">About</a>
        </nav>
    </header>
    <main>
        <h2>About This Blog</h2>
        <p>This static blog is built using HTML, CSS, and Nginx, with Docker for deployment.</p>
    </main>
    <footer>
        <p>&copy; 2025 My Static Blog. All rights reserved.</p>
    </footer>
</body>
</html>
EOF

cat << 'EOF' > "$BASE_DIR/static/style.css"
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background: #f4f4f4;
}

header {
    background: #333;
    color: #fff;
    padding: 10px 0;
    text-align: center;
}

header nav a {
    color: #fff;
    margin: 0 10px;
    text-decoration: none;
}

main {
    padding: 20px;
    text-align: center;
}

footer {
    background: #333;
    color: #fff;
    text-align: center;
    padding: 10px 0;
    position: fixed;
    bottom: 0;
    width: 100%;
}
EOF

# Copy static files to Nginx build context
cp -r "$BASE_DIR/static/"* "$BASE_DIR/nginx/static/"

# Create Nginx configuration
cat << 'EOF' > "$BASE_DIR/nginx/default.conf"
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF

# Create Nginx Dockerfile
cat << 'EOF' > "$BASE_DIR/nginx/Dockerfile"
FROM nginx:latest
COPY default.conf /etc/nginx/conf.d/default.conf
COPY static /usr/share/nginx/html
EOF

# Create Docker Compose file
cat << 'EOF' > "$BASE_DIR/docker-compose.yml"
services:
  nginx:
    build:
      context: ./nginx
    ports:
      - "8080:80"

volumes:
  portainer-data:
EOF

# Create README.md
cat << 'EOF' > "$BASE_DIR/README.md"
# Static Blog Platform

A simple static blog platform built using:
- HTML, CSS, and JavaScript for the frontend
- Nginx for serving static files
- Docker and Docker Compose for containerized deployment

## How to Run
1. Build and start the services:
   ```bash
   docker-compose up --build
2. Check the logs
   docker-compose logs -f
3. Cleanup 
   docker-compose down
