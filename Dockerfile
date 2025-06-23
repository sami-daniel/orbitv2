FROM mcr.microsoft.com/dotnet/sdk:9.0 AS base
WORKDIR /app

COPY *.sln .

COPY src/Orbit.Core/*.csproj ./src/Orbit.Core/
COPY src/Orbit.Infrastructure/*.csproj ./src/Orbit.Infrastructure/
COPY src/Orbit.Container/*.csproj ./src/Orbit.Container/

FROM base AS build
RUN dotnet sln remove src/Orbit.Tests/Orbit.Tests.csproj
RUN dotnet restore
COPY src/. ./src/
RUN dotnet publish src/Orbit.Core/Orbit.Core.csproj -c release -o /build/Orbit.Core --no-restore
RUN dotnet publish src/Orbit.Infrastructure/Orbit.Infrastructure.csproj -c release -o /build/Orbit.Infrastructure --no-restore
RUN dotnet publish src/Orbit.Container/Orbit.Container.csproj -c release -o /build/Orbit.Infrastructure --no-restore

FROM base AS test
COPY src/Orbit.Tests/*.csproj ./src/Orbit.Tests/
RUN dotnet restore
COPY src/. ./src/
RUN dotnet build src/Orbit.Tests/Orbit.Tests.csproj -c Debug --no-restore
ENTRYPOINT ["dotnet", "test", "src/Orbit.Tests/Orbit.Tests.csproj", "--no-build", "--no-restore", "--verbosity", "diagnostic"]
