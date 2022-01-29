#!/usr/bin/env bash

# Tag and push the images to the acr repository
# Before running the script use "az acr login --name <acrName>" OR docker login <acrName> -u <acrId> -p <acrPassword> to setup your docker config.json to azure's acr, else it will fail

# ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER
: ${ACR_LOGIN_SERVER=acrekstest.azurecr.io}
: ${ACR_NAME=acrEksTest}

az acr login --name $ACR_NAME

# The tag for production will be the unique and the first letters of the git commit hash

TAG=$(git log -1 --pretty=%h)

docker build -t $ACR_LOGIN_SERVER/azure-account-microservice:$TAG ./azure-spring-cloud/piggymetrics/account-service
docker build -t $ACR_LOGIN_SERVER/azure-authorization-microservice:$TAG ./azure-spring-cloud/piggymetrics/auth-service
docker build -t $ACR_LOGIN_SERVER/azure-notification-microservice:$TAG ./azure-spring-cloud/piggymetrics/notification-service
docker build -t $ACR_LOGIN_SERVER/azure-statistics-microservice:$TAG ./azure-spring-cloud/piggymetrics/statistics-service

docker push $ACR_LOGIN_SERVER/azure-account-microservice:$TAG
docker push $ACR_LOGIN_SERVER/azure-authorization-microservice:$TAG
docker push $ACR_LOGIN_SERVER/azure-notification-microservice:$TAG
docker push $ACR_LOGIN_SERVER/azure-statistics-microservice:$TAG