######################################################################################################
# File: Dockerfile
#
# Author: Emmanuel Taylor
# Created: April 5, 2025
# Modified: April 5, 2025
# 
# Description:
#   - Dockerfile for the Wordle frontend service. It builds a Node.js container
#     that runs the Express server and connects to MongoDB.
#
# Base Image:
#   - node:18 (Official Node.js LTS image from Docker Hub)
######################################################################################################

# Build Flutter web.
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory inside the build container.
WORKDIR /app

# Copy all source files into the container.
COPY . .

# Enable Flutter web support and fetch dependencies.
RUN flutter config --enable-web
RUN flutter pub get

# Build the Flutter web application fo release.
RUN flutter build web

# Serve using the official NGINX image.
FROM nginx:alpine

# Clean out default NGINX HTML directory.
RUN rm -rf /usr/share/nginx/html/*

# Copy built Flutter web output from build stage.
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom NGINX configuration.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the default HTTP port.
EXPOSE 80

# Start the NGINX server.
CMD ["nginx", "-g", "daemon off;"]