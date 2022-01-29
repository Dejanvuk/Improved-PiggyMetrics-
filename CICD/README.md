# 
# 1. HOW TO: Install Docker and Kubectl
#

# Install Docker
```
apt-get update
```

```
apt-get install build-essential
```
```
apt-get install software-properties-common
```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
```
```
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```
```
apt-get install docker-ce -y
```

# Install Kubectl
```
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
```
```
chmod +x ./kubectl
```
```
mv ./kubectl /usr/local/bin/kubectl
```

# 
# [2. SCRIPT: Create the AKS cluster and configure kubectl to connect to it](../aks/deploy-prod.sh)
#

# 
# [3. SCRIPT: Deploy your K8 objects to the AKS cluster](../kube/deploy-prod.sh)
#

# 
# 4. HOW TO: Build, tag and push new images and push to ACR.
#

# The tag for production will be unique, the first letters of the git commit hash
```
TAG=$(echo ${GIT_COMMIT} | head -c 6)
```
```
ACCOUNT_IMAGE_NAME="${ACR_LOGINSERVER}/azure-account-microservice:$TAG"
AUTHORIZATION_IMAGE_NAME="${ACR_LOGINSERVER}/azure-authorization-microservice:$TAG"
NOTIFICATION_IMAGE_NAME="${ACR_LOGINSERVER}/azure-notification-microservice:$TAG"
STATISTICS_IMAGE_NAME="${ACR_LOGINSERVER}/azure-statistics-microservice:$TAG"
```

# Build & Tag the images 
```
docker build -t $ACCOUNT_IMAGE_NAME ./azure-spring-cloud/piggymetrics/account-service
docker build -t $AUTHORIZATION_IMAGE_NAME ./azure-spring-cloud/piggymetrics/auth-service
docker build -t $NOTIFICATION_IMAGE_NAME ./azure-spring-cloud/piggymetrics/notification-service
docker build -t $STATISTICS_IMAGE_NAME ./azure-spring-cloud/piggymetrics/statistics-service
```

# Before running the script use "az acr login --name <acrName>" OR docker login <acrName> -u <acrId> -p <acrPassword> to setup your docker config.json to azure's acr, else it will fail
```
docker login ${ACR_LOGINSERVER} -u ${ACR_ID} -p ${ACR_PASSWORD}
```

# Push the images to the ACR registry
```
docker push $ACCOUNT_IMAGE_NAME
docker push $AUTHORIZATION_IMAGE_NAME
docker push $NOTIFICATION_IMAGE_NAME
docker push $STATISTICS_IMAGE_NAME
```

# Update the AKS deployments

```
kubectl patch deployment account --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":$ACCOUNT_IMAGE_NAME}]' 
```

```
kubectl patch deployment authorization --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":$AUTHORIZATION_IMAGE_NAME}]' 
```

```
kubectl patch deployment notification --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":$NOTIFICATION_IMAGE_NAME}]' 
```

```
kubectl patch deployment statistics --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":$STATISTICS_IMAGE_NAME}]' 
```





