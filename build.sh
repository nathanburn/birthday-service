#!/bin/bash

serviceName=$1
branchName=$2

echo "Build - Start for '$serviceName' on '$branchName'"

# Stage 1
echo "Git - Clone and Checkout"
# `git clone git@github.com:nathanburn/$serviceName.git``
# `git checkout -b $branchName``
git log -1 --format=%ae # git commit author
# `cd "$serviceName"`

# Stage 2
echo "Semantic Version"
mvn help:evaluate -Dexpression=project.version -q -DforceStdout
# extension - use 'maven-git-versioning-extension'

# Stage 3
echo "Compile Code"
mvn clean package -DskipTests

# Stage 4
echo "Test - Unit Tests"
mvn test

# Stage 5
echo "Static Code Analysis"
# `mvn clean install -P check` (https://github.com/openhab/static-code-analysis/blob/main/docs/maven-plugin.md)

# Stage 6
echo "Artifact (Docker, Terraform, Helm) - Lint, Build, Validate and Publish"

# Docker
# docker build -t local-docker.my-repo.net/$serviceName:v0.1.539 --pull --no-cache -f Dockerfile --build-arg 'BRANCH_NAME=main' --build-arg 'VERSION=0.1.539'

#docker rmi local-docker.my-repo.net/$serviceName:v0.1.539

# Terraform
#./terraform --version
#./terraform init -input=false -backend=false
#./terraform validate
#tar -czf terraform-geo.tgz terraform

# Helm
#helm lint "./deployment/charts/$serviceName"
#cd "deployment/charts"
#tar -czf $serviceName.tgz $serviceName

# Stage 7
echo "Artifact Push and Security Scan"

# Stage 8
echo "Test - Integration and Performance Tests"
docker compose version
#docker compose -f ./dockerComposeBVT/docker-compose.yml -p integration pull --quiet wiremock
#docker compose -f ./dockerComposeBVT/docker-compose.yml -p integration up --detach wiremock
#docker compose -f ./dockerComposeBVT/docker-compose.yml -p integration ps wiremock
#bzt -lint "performance/jenkins-run.yaml"
#bzt "performance/jenkins-run.yaml" "performance/configs/ci-localhost.yaml"
#docker compose -f ./dockerComposeBVT/docker-compose.yml -p integration logs
#docker compose -f ./dockerComposeBVT/docker-compose.yml -p integration down

# Stage 9
echo "Distribute Release Bundle"


echo "Build - End for '$serviceName' on '$branchName'"