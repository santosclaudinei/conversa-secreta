#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["ID_backend/ID_backend.csproj", "ID_backend/"]
COPY ["ID_repository/ID_repository.csproj", "ID_repository/"]
COPY ["ID_model/ID_model.csproj", "ID_model/"]
COPY ["ID_service/ID_service.csproj", "ID_service/"]
RUN dotnet restore "ID_backend/ID_backend.csproj"
COPY . .
WORKDIR "/src/ID_backend"
RUN dotnet build "ID_backend.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ID_backend.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ID_backend.dll"]