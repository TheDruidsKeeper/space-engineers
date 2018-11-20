@echo off
docker build . -t space-engineers
if errorlevel 1 goto END
ECHO Running image
REM docker run -d -p 27016:27016 --rm --name se space-engineers
REM --memory 2g
docker run -it -p 27016:27016/udp -p 8080:8080 --rm -v se-data:C:/World --name se space-engineers powershell
REM taskkill /IM SpaceEngineersDedicated.exe /F
:END