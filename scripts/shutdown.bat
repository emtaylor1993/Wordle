@echo off
echo Shutting Down Docker Containers...
cd ..
docker compose down --volumes --remove-orphans
echo Containers Stopped and Cleaned
pause