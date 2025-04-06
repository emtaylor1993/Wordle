@echo off
echo Starting and Building Docker Containers...
cd ..
docker compose --env-file ./wordle-backend/.env up --build

## Use this to perform a healthcheck.
# docker inspect --format='{{json .State.Health}}' wordle-backend
# docker inspect --format='{{json .State.Health}}' wordle-frontend