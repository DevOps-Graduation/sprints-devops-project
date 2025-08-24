# =========================
# Build stage
# =========================
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# Copy csproj first for better layer caching
# If your file is not named Worker.csproj, adjust the name below.
COPY Worker.csproj ./
RUN dotnet restore

# Copy the rest and publish
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# =========================
# Runtime stage
# =========================
FROM mcr.microsoft.com/dotnet/runtime:7.0 AS final
WORKDIR /app

# (Optional) trim globalization stuff to reduce size a bit
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "Worker.dll"]
