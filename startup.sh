#!/bin/bash

echo "Starting and Building Docker Containers..."
docker compose --env-file ./wordle-backend/.env up --build