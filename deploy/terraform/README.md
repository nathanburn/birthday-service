# Terraform for AWS Infrastructure

![Terraform Diagram](../../docs/imgs/terraform-diagram.png "Terraform Diagram")

Terraform manages the following resources:

- Virtual Private Cloud
- Public and Private Subnet (per Availability Zone)
- Routing tables for the Subnets
- Internet Gateway for Public Subnets
- NAT Gateways with attached Elastic IPs for the Private Subnet
- Security Groups for HTTP access and the configured container port
- Application Load Balancer incl. target group with listeners for port 80
- Elastic Container Registry for the Docker images
- Elastic Container Service  cluster with a service (incl. auto scaling policies for CPU and memory usage)
  and task definition to run docker containers from the ECR (incl. IAM execution role)
- Secrets Manager - a Terraform module creates secrets based on a `map` input value, and has a list of secret ARNs as output values
