@echo off
echo Shutting Down Docker Containers...
docker compose down --volumes --remove-orphans
echo Containers Stopped and Cleaned
pause