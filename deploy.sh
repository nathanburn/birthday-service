#!/bin/bash

serviceName=$1
envName=$2

echo "Deploy - Start for '$serviceName' to '$envName'"

# Stage 1
echo "Retrieve Release Bundle Artifacts"

# Stage 2
echo "Validate Release Artifacts"

# Stage 3
echo "Push Docker Images to Cloud ACR"

# Stage 4
echo "Apply Terraform"

# Stage 5
echo "Upgrade (install) Helm Charts with Rolling Update strategy"

# Stage 6
echo "Helm Test - Integration and Performance Tests"

# Stage 7
read -p "Promote '$envName' as Primary Environment? (y/n) " yn

case $yn in 
    [yY] ) echo "Promoted live '$serviceName' traffic to '$envName'.";;
    [nN] ) echo "No promotion for '$envName', investigation required.";;
    * ) echo "Invalid response.";;
esac

echo "Deploy - End for '$serviceName' to '$envName'"
