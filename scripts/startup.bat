@echo off
echo Starting and Building Docker Containers...
cd ..
docker compose --env-file ./wordle-backend/.env up --build