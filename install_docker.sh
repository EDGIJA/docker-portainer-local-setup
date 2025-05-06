#!/bin/bash

echo "⏱️🐳 Installing Docker Engine on Ubuntu..."

# Prerequisites
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# GPG keys
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Repository source
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable service and permissions
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

echo "✅🐳 Docker installed. Restart your session to use it without sudo."
