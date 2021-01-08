FROM mcr.microsoft.com/dotnet/sdk:3.1 AS dotnet-build
WORKDIR /src
COPY . /src
RUN dotnet restore "demo-app.csproj"
RUN dotnet build "demo-app.csproj" -c Release -o /app/build

FROM dotnet-build AS dotnet-publish
RUN dotnet publish "demo-app.csproj" -c Release -o /app/publish

FROM node AS node-builder
WORKDIR /node
COPY ./ClientApp /node
RUN npm install
RUN npm build

FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS final
WORKDIR /app
EXPOSE 5050
RUN mkdir /app/wwwroot
COPY --from=dotnet-publish /app/publish .
COPY --from=node-builder /node/build ./wwwroot
ENTRYPOINT ["dotnet", "demo-app.dll"]

