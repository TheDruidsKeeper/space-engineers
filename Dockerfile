#escape=`
FROM microsoft/windowsservercore:ltsc2016
#FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

LABEL maintainer="TheDruidsKeeper"
EXPOSE 27016/UDP
EXPOSE 8080/TCP
VOLUME C:\world

#Install from steam:
#	https://developer.valvesoftware.com/wiki/SteamCMD#Windows
#	https://www.spaceengineersgame.com/dedicated-servers.html
### NOTE: This won't keep the image updated with the latest server, even when you rebuild since it will cache this layer.
RUN Write-Host "Downloading steamcmd"; `
	Invoke-WebRequest -OutFile steamcmd.zip -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"; `
	Write-Host "Extracting zip"; `
	Expand-Archive steamcmd.zip -DestinationPath C:\steamcmd; `
	Remove-Item steamcmd.zip; `
	Write-Host "Installing dedicated server"; `
	C:\steamcmd\steamcmd.exe +login anonymous +force_install_dir c:\SpaceEngineers +app_update 298740 +quit; `
	Write-Host "Validating the install since the initial install seems to always fail"; `
	C:\steamcmd\steamcmd.exe +login anonymous +force_install_dir c:\SpaceEngineers +app_update 298740 validate +quit; `
	Write-Host "SE Dedicated Server is installed and ready for action";

# TODO: https://docs.docker.com/engine/reference/builder/#healthcheck
#HEALTHCHECK CMD try { `
#     $response = iwr http://localhost:8080 -UseBasicParsing; `
#     if ($response.StatusCode -eq 200) { return 0} `
#     else {return 1}; `
#    } catch { return 1 }

#COPY ./SpaceEngineers-Dedicated.cfg /world/SpaceEngineers-Dedicated.cfg
CMD Write-Host "Updating Dedicated Server"; `
	C:\steamcmd\steamcmd.exe +login anonymous +force_install_dir c:\SpaceEngineers +app_update 298740 +quit; `
	Write-Host "Launching Dedicated Server"; `
	Start-Process -WorkingDirectory C:\SpaceEngineers\DedicatedServer64 -FilePath SpaceEngineersDedicated.exe -Wait -ArgumentList \"-console\",\"-path\",\"C:\world\";
