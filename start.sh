#!/bin/bash

echo "Stopping Running Container: $(docker stop eureka-server)"
echo "Deleting Existing Container: $(docker rm eureka-server)"

mvn clean install -DskipTests
mkdir -p target/dependency
cd target/dependency && jar -xf ../*.jar && cd -

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
echo "Tagging Old Binary with: $TIMESTAMP"

docker tag eureka-server:latest eureka-server:$TIMESTAMP
docker build -t eureka-server:latest .

#docker run --name eureka-server -p 8080:8080 -e DB_HOST=postgres --network database -d eureka-server
docker run --name eureka-server --network=host -d eureka-server