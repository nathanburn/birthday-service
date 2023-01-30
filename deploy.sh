#!/bin/bash

serviceName=$1
semVer=$2
envName=$3
kubeconfig="kubeconfig-$envName"

echo "Deploy - Start for '$serviceName' to '$envName'"

# Stage 1
echo "Retrieve Release Bundle Artifacts"

# Stage 2
echo "Validate Release Artifacts"
echo "CheckSum validation of Docker images, and cross reference to the Grafeas - Build Note"

# Stage 3
echo "Terraform Apply"
echo "oras pull -u [USERNAME] -p (aws ecr get-login-password) [AWS_ACCOUNT_ID].dkr.ecr.region.amazonaws.com:opa-temporal-0 --media-type application/vnd.cncf.helm.chart.layer.v1.tar+gzip"
echo "tar -xvf $serviceName"
echo "terraform plan"
echo "terraform apply"

# Stage 4
echo "Upgrade (install) Helm Charts with Rolling Update strategy"
echo "helm version --kubeconfig $kubeconfig"
echo "helm upgrade $serviceName --namespace --install --create-namespace $envName oci://aws_account_id.dkr.ecr.region.amazonaws.com/$serviceName --version $semVer --set 'image.tag=$semVer' --kubeconfig $kubeconfig --wait"
echo "helm list --namespace $envName --kubeconfig $kubeconfig"
echo "Grafeas - Deployment Attestation - created and updated"

# Stage 5
echo "Helm Test - Integration and Performance Tests"
echo "helm test $serviceName --kubeconfig $kubeconfig"
echo "Grafeas - Test Attestation - created and updated"

# Stage 6
read -p "Promote '$envName' as Primary Environment? (y/n) " yn

case $yn in 
    [yY] ) echo "Promoted live '$serviceName' traffic to '$envName'.";;
    [nN] ) echo "No promotion for '$envName', investigation required.";;
    * ) echo "Invalid response.";;
esac

echo "Deploy - End for '$serviceName' to '$envName'"
