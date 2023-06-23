#!/bin/bash

# Comment out the CDROM sources for apt 
sudo sed -i.bak -r '/deb cdrom:/s/^/#/' /etc/apt/sources.list 

# Install curl
sudo apt install curl -y
