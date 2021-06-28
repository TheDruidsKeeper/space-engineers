#escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

LABEL maintainer="TheDruidsKeeper"
EXPOSE 27016/UDP
EXPOSE 8080/TCP
VOLUME C:\world
ENV secret=empty

# Install C++ runtimes required by Space Engineers
#   https://www.reddit.com/r/spaceengineers/comments/bxzr4s/dedicatedserver64_problem_havokdll_not_found/
# 2013 C++ Runtime:
ADD https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe /vcredist_x64.exe
RUN Start-Process -filepath C:\vcredist_x64.exe -ArgumentList "/install","/passive","/norestart","'/vc2013_install.log'" -PassThru | wait-process
# 2015 C++ Runtime:
ADD https://download.microsoft.com/download/6/A/A/6AA4EDFF-645B-48C5-81CC-ED5963AEAD48/vc_redist.x64.exe /vc_redist.x64.exe
RUN Start-Process -filepath C:\vc_redist.x64.exe -ArgumentList "/install","/passive","/norestart","'/vc2015_install.log'" -PassThru | wait-process

# SteamCMD
#	https://developer.valvesoftware.com/wiki/SteamCMD#Windows
ADD https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip /steamcmd.zip
RUN Write-Host "Extracting steamcmd"; `
	Expand-Archive steamcmd.zip -DestinationPath C:\steamcmd; `
	Remove-Item steamcmd.zip;

# Install Space Engineers via steamcmd:
#	https://www.spaceengineersgame.com/dedicated-servers.html
### NOTE: This won't keep the image updated with the latest server, even when you rebuild since it will cache this layer.
RUN Write-Host "Installing dedicated server"; `
	C:\steamcmd\steamcmd.exe +login anonymous +force_install_dir c:\SpaceEngineers +app_update 298740 +quit; `
	Write-Host "Validating the install since the initial install seems to always fail"; `
	C:\steamcmd\steamcmd.exe +login anonymous +force_install_dir c:\SpaceEngineers +app_update 298740 validate +quit; `
	Write-Host "SE Dedicated Server is installed and ready for action";

COPY ./scripts C:/scripts/
	
# https://docs.docker.com/engine/reference/builder/#healthcheck
HEALTHCHECK --interval=30s --timeout=60s --start-period=90s CMD powershell -File c:/scripts/health-check.ps1

#COPY ./SpaceEngineers-Dedicated.cfg /world/SpaceEngineers-Dedicated.cfg
CMD Write-Host "Updating Dedicated Server"; `
	C:\steamcmd\steamcmd.exe +login anonymous +force_install_dir c:\SpaceEngineers +app_update 298740 +quit; `
	Write-Host "Launching Dedicated Server"; `
	C:\scripts\setup.bat
	Start-Process -WorkingDirectory C:\SpaceEngineers\DedicatedServer64 -FilePath SpaceEngineersDedicated.exe -Wait -ArgumentList \"-console\",\"-path\",\"C:\world\";
	
