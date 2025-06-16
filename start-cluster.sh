#!/bin/bash

echo "Stopping Running Container: "
docker stop $(docker ps -a | grep eureka-server- | awk '{print $1}')
echo "Deleting Existing Container: "
docker rm $(docker ps -a | grep eureka-server- | awk '{print $1}')

mvn clean install -DskipTests
mkdir -p target/dependency
cd target/dependency && jar -xf ../*.jar && cd -

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
echo "Tagging Old Binary with: $TIMESTAMP"

docker tag eureka-server:latest eureka-server:$TIMESTAMP
docker build -t eureka-server:latest .

#docker run --name eureka-server -p 8080:8080 -e DB_HOST=postgres --network database -d eureka-server
docker run --name eureka-peer1 --network=host -e SPRING_PROFILES_ACTIVE=peer1 -d eureka-server
docker run --name eureka-peer2 --network=host -e SPRING_PROFILES_ACTIVE=peer2 -d eureka-server
docker run --name eureka-peer3 --network=host -e SPRING_PROFILES_ACTIVE=peer3 -d eureka-server