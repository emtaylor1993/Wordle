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

FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
RUN flutter config --enable-web
RUN flutter pub get
RUN flutter build web
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]