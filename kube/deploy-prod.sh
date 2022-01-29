#!/usr/bin/env bash

# A helper script to create the Kubernetes resources

# ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER
: ${ACR_LOGIN_SERVER=acrekstest.azurecr.io}

: ${AKS_NAMESPACE=myakscluster-prod}

# Print all commands and stop executing if one fails

set -ex

# Create and setup the namespace for all the cluster's resources

kubectl create namespace $AKS_NAMESPACE

kubectl config set-context --current --namespace=$AKS_NAMESPACE

# Deploy a NGINX ingress controller in the AKS cluster (requires Helm 3+)

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm install nginx-ingress ingress-nginx/ingress-nginx \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux

sleep 10s

# Store application configurations in configmaps for each service

kubectl create configmap configmap-account --from-file=../resources-config/application.yml --from-file=../resources-config/account.yml --save-config
kubectl create configmap configmap-authorization --from-file=../resources-config/application.yml --from-file=../resources-config/authorization.yml --save-config
kubectl create configmap configmap-notification --from-file=../resources-config/application.yml --from-file=../resources-config/notification.yml --save-config
kubectl create configmap configmap-statistic --from-file=../resources-config/application.yml --from-file=../resources-config/statistic.yml --save-config
kubectl create configmap definitions-configmap --from-file=../rabbitmq-definition/definitions.json --save-config

# The username and passwords to access various remote services are stored in secrets

kubectl create secret generic mongodb-credentials \
    --from-literal=SPRING_DATA_MONGODB_USERNAME=user \
    --from-literal=SPRING_DATA_MONGODB_PASSWORD=password \
    --save-config

kubectl create secret generic encrypt-key \
    --from-literal=ENCRYPT_KEY=config_server_encrypt_key \
    --save-config

kubectl create secret generic account-service \
    --from-literal=ACCOUNT_SERVICE_PASSWORD=password \
    --save-config

kubectl create secret generic statistics-service \
    --from-literal=STATISTICS_SERVICE_PASSWORD=password \
    --save-config

kubectl create secret generic notification-service \
    --from-literal=NOTIFICATION_SERVICE_PASSWORD=password \
    --save-config

kubectl create secret generic config-service \
    --from-literal=CONFIG_SERVICE_PASSWORD=password \
    --save-config

kubectl create secret generic mongodb-server-credentials \
    --from-literal=MONGO_INITDB_ROOT_PASSWORD=password \
    --save-config

# Deploy all the resources

kubectl apply -k overlays/prod

kubectl wait --timeout=500s --for=condition=ready pod --all

set +ex