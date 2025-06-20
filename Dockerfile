FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

COPY *.sln .

COPY src/Orbit.Core/*.csproj ./src/Orbit.Core/
COPY src/Orbit.Infrastructure/*.csproj ./src/Orbit.Infrastructure/
# we separate this cuz docker will cache each layer (almost each command)
# so when testing, if the dependencies didn't change, it will jump the 
# restore and use the cached dep instead, and only compile the .cs files
# that changed
RUN dotnet restore

COPY src/Orbit.Core/. ./Orbit.Core/
COPY src/Orbit.Infrastructure/. ./Orbit.Infrastructure/
# compile the code in release mode and put the final binary
# in /build folder
RUN dotnet publish -c release -o /build --no-restore
