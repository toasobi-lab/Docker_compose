#!/bin/bash

# Set the base directory
BASE_DIR=$(pwd)/blog-platform

# Create directories
mkdir -p "$BASE_DIR/frontend"
mkdir -p "$BASE_DIR/backend"

# Create frontend files
cat << 'EOF' > "$BASE_DIR/frontend/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blog Platform</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Blog Platform</h1>
    <form id="postForm">
        <input type="text" id="titleInput" placeholder="Post Title" required />
        <textarea id="contentInput" placeholder="Post Content" required></textarea>
        <button type="submit">Add Post</button>
    </form>
    <ul id="postList"></ul>

    <script src="script.js"></script>
</body>
</html>
EOF

cat << 'EOF' > "$BASE_DIR/frontend/style.css"
body {
    font-family: Arial, sans-serif;
    margin: 20px;
    padding: 0;
    background-color: #f8f9fa;
    text-align: center;
}

form {
    margin: 20px auto;
}

textarea {
    width: 80%;
    height: 100px;
    margin-bottom: 10px;
}

ul {
    list-style: none;
    padding: 0;
}
EOF

cat << 'EOF' > "$BASE_DIR/frontend/script.js"
const postForm = document.getElementById('postForm');
const postList = document.getElementById('postList');

postForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const title = document.getElementById('titleInput').value;
    const content = document.getElementById('contentInput').value;

    const response = await fetch('http://localhost:3000/api/posts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, content })
    });

    if (response.ok) {
        loadPosts();
        postForm.reset();
    } else {
        alert('Failed to add post.');
    }
});

async function loadPosts() {
    const response = await fetch('http://localhost:3000/api/posts');
    const posts = await response.json();
    postList.innerHTML = '';
    posts.forEach(post => {
        const li = document.createElement('li');
        li.innerHTML = `
            <h3>${post.title}</h3>
            <p>${post.content}</p>
            <button onclick="deletePost('${post._id}')">Delete</button>
        `;
        postList.appendChild(li);
    });
}

async function deletePost(id) {
    await fetch(`http://localhost:3000/api/posts/${id}`, { method: 'DELETE' });
    loadPosts();
}

loadPosts();
EOF

cat << 'EOF' > "$BASE_DIR/frontend/Dockerfile"
FROM node:16
WORKDIR /app
COPY . .
RUN npm install -g http-server
CMD ["http-server", "-p", "8080"]
EOF

# Create backend files
cat << 'EOF' > "$BASE_DIR/backend/app.js"
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

mongoose.connect('mongodb://mongo:27017/blog', {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

const postSchema = new mongoose.Schema({
    title: String,
    content: String
});

const Post = mongoose.model('Post', postSchema);

// Get all posts
app.get('/api/posts', async (req, res) => {
    const posts = await Post.find({});
    res.json(posts);
});

// Add a new post
app.post('/api/posts', async (req, res) => {
    const { title, content } = req.body;
    const newPost = new Post({ title, content });
    await newPost.save();
    res.status(201).json(newPost);
});

// Delete a post
app.delete('/api/posts/:id', async (req, res) => {
    await Post.findByIdAndDelete(req.params.id);
    res.status(204).send();
});

app.listen(3000, () => {
    console.log('Backend running on port 3000');
});
EOF

cat << 'EOF' > "$BASE_DIR/backend/package.json"
{
  "name": "backend",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "body-parser": "^1.20.2",
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "mongoose": "^7.0.4"
  }
}
EOF

cat << 'EOF' > "$BASE_DIR/backend/Dockerfile"
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["node", "app.js"]
EOF

# Create docker-compose.yml
cat << 'EOF' > "$BASE_DIR/docker-compose.yml"
version: "3.8"
services:
  frontend:
    build:
      context: ./frontend
    ports:
      - "8080:8080"
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
    ports:
      - "3000:3000"
    depends_on:
      - mongo

  mongo:
    image: mongo:6.0
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

  mongo-express:
    image: mongo-express:latest
    ports:
      - "8081:8081"
    environment:
      ME_CONFIG_MONGODB_SERVER: mongo
      ME_CONFIG_BASICAUTH_USERNAME: admin
      ME_CONFIG_BASICAUTH_PASSWORD: pass

  portainer:
    image: portainer/portainer-ce
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer-data:/data

volumes:
  mongo-data:
  portainer-data:
EOF

# Create README.md
cat << 'EOF' > "$BASE_DIR/README.md"
# Blog Platform

A simple CRUD-based blog platform with Docker Compose.

## Features
- **Frontend**: Add and view blog posts.
- **Backend**: REST API for blog operations.
- **Database**: MongoDB to store posts.
- **Mongo Express**: Manage the database.
- **Portainer**: Monitor Docker containers.

## How to Run
1. Build and start the services:
   ```bash
   docker-compose up --build
