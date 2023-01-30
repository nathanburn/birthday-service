#!/bin/bash

serviceName=$1
branchName=$2

echo "Build - Start for '$serviceName' on '$branchName'"

# Stage 1
echo "Git - Clone and Checkout"
echo "git clone git@github.com:nathanburn/$serviceName.git"
echo "cd '$serviceName'"
echo "git checkout -b '$branchName'"
author=$(git log -1 --format=%ae) # git commit author
echo "Author: $author"

# Stage 2
echo "Semantic Version"
semVer=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout) # extend with 'maven-git-versioning-extension'
echo "semVer: $semVer" 

# Stage 3
echo "Compile Code"
mvn clean package -DskipTests

# Stage 4
echo "Test - Unit Tests"
mvn test

# Stage 5
echo "Static Code Analysis"
echo "mvn clean install -P check" # (https://github.com/openhab/static-code-analysis/blob/main/docs/maven-plugin.md)
echo "Push coverage results to SonarQube (or a similar static code analysis tool)"

# Stage 6
echo "Artifact (Docker, Terraform, Helm) - Lint, Build, Validate and Publish"

# Docker
docker build -t "$serviceName" .
docker images --filter "reference=$serviceName"
echo "aws ecr get-login-password --region [REGION] | docker login --username [USERNAME] --password-stdin [AWS_ACCOUNT_ID].dkr.ecr.region.amazonaws.com"
echo "docker tag $serviceName:$semVer [AWS_ACCOUNT_ID].dkr.ecr.region.amazonaws.com/$serviceName-repository"
echo "docker push [AWS_ACCOUNT_ID].dkr.ecr.region.amazonaws.com/$serviceName-repository"

# Terraform
terraform version
terraform -chdir="deploy/resources" init
terraform -chdir="deploy/resources" validate
echo "terraform -chdir="deploy/resources" plan"
echo "tar czf $serviceName-terraform.tar.gz deploy/resources"
echo "oras push -u AWS -p $(aws ecr get-login-password) [AWS_ACCOUNT_ID].dkr.ecr.region.amazonaws.com:opa-temporal-0 --manifest-config empty-config.json:application/vnd.cncf.openpolicyagent.config.v1+json bundle.tar.gz:application/vnd.cncf.openpolicyagent.manifest.layer.v1+json"

# Helm
helm version
helm lint "./deploy/charts/$serviceName"
helm package "./deploy/charts/$serviceName" --version $semVer
echo "aws ecr get-login-password --region [REGION] | helm registry login --username [USERNAME] --password-stdin [AWS_ACCOUNT_ID].dkr.ecr.region.amazonaws.com"
echo "helm push $serviceName-$semVer.tgz oci://[AWS_ACCOUNT_ID].dkr.ecr.region.amazonaws.com/"

# Stage 7
echo "Artifact Security Scan"
echo "Scanned published artifacts (Docker, Helm and Terraform) for CVE and recommended security patches e.g. Snyk or JFrog Xray"

# Stage 8
echo "Test - Integration and Performance Tests"
docker compose version
docker compose up -d
docker compose ps
docker compose logs
echo "bzt -lint 'performance/main.yaml'"
echo "bzt 'performance/main.yaml' 'performance/configs/ci-localhost.yaml'"
docker compose down

# Stage 9
echo "Distribute Release Bundle"
echo "Group the published artifacts into a "Release Bundle" (e.g. manifest JSON) by service name and semantic version, and push to a registry which the deploy tool (e.g. Jenkins) is subscribed to."

echo "Grafeas - Build Note - created and updated with each stage"

echo "Build - End for '$serviceName' on '$branchName'"