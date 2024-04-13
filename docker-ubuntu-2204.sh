#!/bin/bash

# https://docs.docker.com/engine/install/ubuntu/
# this script was created 2024-04-13

# uninstall all conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Set up Docker's apt repository

# Add Docker's official GPG key:
echo setting up Docker apt repo...
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker packages.
echo installing Docker packages...
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue
echo adding Docker user...
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
echo restarting Docker...
sudo systemctl restart docker
