######################################################################################################
# File: Dockerfile
#
# Author: Emmanuel Taylor
# Created: April 3, 2025
# Modified: April 3, 2025
# 
# Description:
#   - Dockerfile for the Wordle backend service. It builds a Node.js container
#     that runs the Express server and connects to MongoDB.
#
# Base Image:
#   - node:18 (Official Node.js LTS image from Docker Hub)
######################################################################################################

FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "node", "server.js" ]