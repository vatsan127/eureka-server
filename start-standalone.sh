#!/bin/bash

# Connect to Minikube's Docker daemon
eval $(minikube -p minikube docker-env)

echo "Stopping Running Container: $(docker stop eureka-server 2>/dev/null || true)"
echo "Deleting Existing Container: $(docker rm eureka-server 2>/dev/null || true)"

# Build the application
mvn clean install -DskipTests
mkdir -p target/dependency
cd target/dependency && jar -xf ../*.jar && cd -

# Tag and build Docker image
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
echo "Tagging Old Binary with: $TIMESTAMP"

docker tag eureka-server:latest eureka-server:$TIMESTAMP 2>/dev/null || true
docker build -t eureka-server:latest .

echo "pwd - $(pwd)"

# Apply k8s config and force restart
kubectl apply -f ./k8s.yml
kubectl rollout restart deployment eureka-server