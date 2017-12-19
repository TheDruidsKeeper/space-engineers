FROM microsoft/dotnet-framework:4.6.2
LABEL maintainer="TheDruidsKeeper"
EXPOSE 27016/UDP
#VOLUME D:\\bin D:\\Worlds
#WORKDIR D:\\bin
COPY ./Scripts C:\\Scripts
CMD ["powershell.exe", "C:\\Scripts\\Start.ps1"]
