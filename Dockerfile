FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

COPY *.sln .

COPY src/Orbit.Core/*.csproj ./src/Orbit.Core/
COPY src/Orbit.Infrastructure/*.csproj ./src/Orbit.Infrastructure/

# exclude the test projects from the build context
RUN dotnet sln remove src/Orbit.Tests/Orbit.Tests.csproj

# we restore separated this cuz docker will cache each layer (almost each command)
# so when testing, if the dependencies didn't change, it will jump the 
# restore and use the cached dep instead, and only compile the .cs files
# that changed
RUN dotnet restore

# copy the rest of the code
COPY src/Orbit.Core/. ./Orbit.Core/
COPY src/Orbit.Infrastructure/. ./Orbit.Infrastructure/

# compile the code in release mode and put the final output in /build
RUN dotnet publish src/Orbit.Core/Orbit.Core.csproj -c release -o /build/Orbit.Core --no-restore
RUN dotnet publish src/Orbit.Infrastructure/Orbit.Infrastructure.csproj -c release -o /build/Orbit.Infrastructure --no-restore
