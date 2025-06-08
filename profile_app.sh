#!/bin/bash

# Set the base directory
BASE_DIR=$(pwd)/profile_app

# Create the directory structure
mkdir -p "$BASE_DIR/frontend"
mkdir -p "$BASE_DIR/backend"

# Create files for frontend
cat << 'EOF' > "$BASE_DIR/frontend/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enhanced Profile App</title>
    <style>
        #profilePreview {
            margin-top: 20px;
        }
        #profilePreview img {
            max-width: 100px;
            border-radius: 50%;
        }
    </style>
</head>
<body>
    <h1>Enhanced Profile App</h1>
    <form id="profileForm">
        <label for="avatar">Avatar URL:</label>
        <input type="text" id="avatar" name="avatar" placeholder="Leave blank for default avatar"><br><br>
        
        <label for="name">Name:</label>
        <input type="text" id="name" name="name" required><br><br>
        
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required><br><br>
        
        <label for="bio">Bio:</label>
        <textarea id="bio" name="bio" rows="3" placeholder="Tell us about yourself..."></textarea><br><br>
        
        <label for="location">Location:</label>
        <input type="text" id="location" name="location" placeholder="e.g., San Francisco"><br><br>
        
        <button type="submit">Update Profile</button>
    </form>

    <div id="profilePreview">
        <h2>Profile Preview</h2>
        <img id="avatarPreview" src="https://via.placeholder.com/100" alt="Avatar">
        <p><strong>Name:</strong> <span id="namePreview">N/A</span></p>
        <p><strong>Email:</strong> <span id="emailPreview">N/A</span></p>
        <p><strong>Bio:</strong> <span id="bioPreview">N/A</span></p>
        <p><strong>Location:</strong> <span id="locationPreview">N/A</span></p>
    </div>
    <script src="script.js"></script>
</body>
</html>
EOF

cat << 'EOF' > "$BASE_DIR/frontend/script.js"
const form = document.getElementById("profileForm");

form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const avatar = document.getElementById("avatar").value || "https://via.placeholder.com/100";
    const name = document.getElementById("name").value;
    const email = document.getElementById("email").value;
    const bio = document.getElementById("bio").value;
    const location = document.getElementById("location").value;

    const response = await fetch("http://localhost:3000/api/profile", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ avatar, name, email, bio, location }),
    });

    if (response.ok) {
        const updatedProfile = await response.json();
        updateProfilePreview(updatedProfile);
        alert("Profile updated!");
    } else {
        alert("Failed to update profile.");
    }
});

async function fetchProfile() {
    const response = await fetch("http://localhost:3000/api/profile");
    if (response.ok) {
        const profile = await response.json();
        updateProfilePreview(profile);
    }
}

function updateProfilePreview(profile) {
    document.getElementById("avatarPreview").src = profile.avatar || "https://via.placeholder.com/100";
    document.getElementById("namePreview").textContent = profile.name || "N/A";
    document.getElementById("emailPreview").textContent = profile.email || "N/A";
    document.getElementById("bioPreview").textContent = profile.bio || "N/A";
    document.getElementById("locationPreview").textContent = profile.location || "N/A";
}

// Fetch profile data on page load
fetchProfile();
EOF

cat << 'EOF' > "$BASE_DIR/frontend/Dockerfile"
FROM node:16
WORKDIR /app
COPY . .
RUN npm install -g http-server
CMD ["http-server", "-p", "8080"]
EOF

# Create files for backend
cat << 'EOF' > "$BASE_DIR/backend/app.js"
const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(bodyParser.json());

mongoose.connect("mongodb://mongo:27017/profiles", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

const profileSchema = new mongoose.Schema({
    avatar: { type: String, default: "https://via.placeholder.com/100" },
    name: { type: String, required: true },
    email: { type: String, required: true },
    bio: { type: String },
    location: { type: String },
});

const Profile = mongoose.model("Profile", profileSchema);

app.post("/api/profile", async (req, res) => {
    const { avatar, name, email, bio, location } = req.body;
    try {
        const profile = await Profile.findOneAndUpdate(
            {},
            { avatar, name, email, bio, location },
            { upsert: true, new: true }
        );
        res.status(200).json(profile);
    } catch (err) {
        res.status(500).json({ error: "Failed to update profile" });
    }
});

app.get("/api/profile", async (req, res) => {
    try {
        const profile = await Profile.findOne({});
        res.json(profile || {
            avatar: "https://via.placeholder.com/100",
            name: "N/A",
            email: "N/A",
            bio: "N/A",
            location: "N/A",
        });
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch profile" });
    }
});

app.listen(3000, () => console.log("Backend running on port 3000"));
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
      - "8085:8080"
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

volumes:
  mongo-data:
EOF

# Create README.md
cat << 'EOF' > "$BASE_DIR/README.md"
# Enhanced Profile App

This app demonstrates Docker-based deployment of a profile management system. It includes:
- A **frontend** to manage profile info.
- A **backend** powered by Node.js and MongoDB.
- **Mongo Express** for database management.

## How to Run

1. Build and start the app:
   ```bash
   docker-compose up --build
