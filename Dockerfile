FROM mcr.microsoft.com/dotnet/sdk:7.0 AS installer-env
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    curl \
    git \
    gnupg \
    procps \
    unzip \
    wget \
    zip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

RUN npm i -g azure-functions-core-tools@4 --unsafe-perm true
COPY . .
RUN cd /src && \
    mkdir -p /home/site/wwwroot 
RUN cd src && \
    func extensions sync && \
    npm install && \
    npm run generate && \
    npm prune --production
# To enable ssh & remote debugging on app  service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/dotnet:4-appservice
FROM mcr.microsoft.com/azure-functions/node:4-node18
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=installer-env ["/src", "/home/site/wwwroot"]