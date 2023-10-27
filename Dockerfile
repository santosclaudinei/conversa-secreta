# Build the ASP.NET Core Web API project
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-webapi
WORKDIR /app

# Copy and restore the Web API project
COPY ID_backend/ID_backend.csproj ./ID_backend/
RUN dotnet restore ./ID_backend/ID_backend.csproj

# Copy the rest of the Web API project files
COPY ID_backend/ ./ID_backend/
WORKDIR /app/ID_backend

# Build and publish the Web API project
RUN dotnet publish -c Release -o out

# Build the library projects
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-libraries
WORKDIR /app

# Copy and restore the library projects
COPY ID_model/ID_model.csproj ./ID_model/
COPY ID_repository/ID_repository.csproj ./ID_repository/
COPY ID_service/ID_service.csproj ./ID_service/
RUN dotnet restore ./ID_model/ID_model.csproj
RUN dotnet restore ./ID_repository/ID_repository.csproj
RUN dotnet restore ./ID_service/ID_service.csproj

# Copy the rest of the library project files
COPY ID_model/ ./ID_model/
COPY ID_repository/ ./ID_repository/
COPY ID_service/ ./ID_service/

# Build the library projects
RUN dotnet build ./ID_model/ID_model.csproj -c Release -o out
RUN dotnet build ./ID_repository/ID_repository.csproj -c Release -o out
RUN dotnet build ./ID_service/ID_service.csproj -c Release -o out

# Build the final image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app
EXPOSE 80

# Copy the published Web API project
COPY --from=build-webapi /app/ID_backend/out .

# Copy the built libraries
COPY --from=build-libraries /app/ID_model/out ./ID_model/
COPY --from=build-libraries /app/ID_repository/out ./ID_repository/
COPY --from=build-libraries /app/ID_service/out ./ID_service/

ENTRYPOINT ["dotnet", "ID_backend.dll"]


# # Use the official ASP.NET Core runtime image as a base
# FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base

# # Define como diretório de trabalho a pasta /app
# WORKDIR /app

# # Expõe a porta 80 dentro do container
# EXPOSE 80 443

# # Use the official ASP.NET Core SDK image to build the app
# FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

# # Define a origem dos arquivos a serem utilizados em seguida
# WORKDIR /src

# # Copia os arquivos do projeto e restaura as dependências
# COPY ["ID_backend/ID_backend.csproj", "ID_backend/"]
# COPY ["ID_model/ID_model.csproj", "ID_model/"]
# COPY ["ID_repository/ID_repository.csproj", "ID_repository/"]
# COPY ["ID_service/ID_service.csproj", "ID_service/"]

# # Restaura as dependências do projeto.
# RUN dotnet restore "ID_backend/ID_backend.csproj"

# # Copia todos os arquivos e pastas do diretório de origem
# COPY . .

# # Define novamente o diretório de trabalho atual como "/src/hackweek-backend"
# WORKDIR "/src/ID_backend"

# # Compila o projeto e define o diretório de saída como "/app/build"
# RUN dotnet build "ID_backend.csproj" -c Release -o /app/build

# # Publica o aplicativo
# FROM build AS publish

# # Publica o aplicativo e define o diretório de saída como "/app/publish"
# RUN dotnet publish "ID_backend.csproj" -c Release -o /app/publish

# # Use a base image e copie o aplicativo publicado
# FROM base AS final

# # Define o diretório de trabalho atual como "/app"
# WORKDIR /app

# # Copia os arquivos publicados da etapa "publish" para o diretório de trabalho atual da etapa "final"
# COPY --from=publish /app/publish .

# # Define o comando de entrada para o contêiner
# ENTRYPOINT ["dotnet", "ID_backend.dll"]