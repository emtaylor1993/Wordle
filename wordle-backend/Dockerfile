######################################################################################################
# File: Dockerfile
#
# Author: Emmanuel Taylor
# Created: April 3, 2025
# Modified: April 5, 2025
# 
# Description:
#   - Dockerfile for the Wordle backend service. It builds a Node.js container
#     that runs the Express server and connects to MongoDB.
#
# Base Image:
#   - node:18 (Official Node.js LTS image from Docker Hub)
######################################################################################################

# Use official Node.js LTS version as base image.
FROM node:18                  

# Sets the working directory inside the container.
WORKDIR /app

# Copy package filse first to leverage the Docker cache.
COPY package*.json ./

# Install application dependencies.
RUN npm install

# Copy the rest of the application source code.
COPY . .

# Expose the port the server will run on.
EXPOSE 3000

# Define the default command to run the application.
CMD [ "node", "server.js" ]