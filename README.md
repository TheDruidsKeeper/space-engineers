# space-engineers
A windows docker image for running the Space Engineers dedicated server, published to the [docker hub](https://hub.docker.com/repository/docker/thedruidskeeper/space-engineers).

## Features:
- Windows server core 2019 base image
- Includes all required dependencies
- Updates the dedicated server on container start
- Persistent volume for storing world data
- Healthcheck monitors the dedicated server's ping (see the [Remote API](https://www.spaceengineersgame.com/dedicated-servers.html) documentation)

## Usage:
1. Create a persistent volume to store world data:
```powershell
docker volume create se-data
```
2. Copy your `SpaceEngineers-Dedicated.cfg` onto the root of the new volume
    1. Default path would be here: `C:\ProgramData\Docker\volumes\se-data\_data\SpaceEngineers-Dedicated.cfg`
3. Start the container
    1. Replace `[YOUR_SECRET_HERE]` with your own remote api secret (required for the docker [Healthcheck](https://github.com/TheDruidsKeeper/space-engineers/blob/master/scripts/health-check.ps1))
```powershell
docker run -dit --restart unless-stopped -p 27016:27016/udp -p 8080:8080 -v se-data:C:\World -e "secret=[YOUR_SECRET_HERE]" --name se thedruidskeeper/space-engineers:latest
```
:star2: **Protip:** Rather than using a named volume you could just mount a local folder (ex: `-v z:\se-data:c:\World`)

Restart the container whenever a new release comes out (to initiate the automatic update):
```powershell
docker restart se
```
