# SimpleTimeService deployment challenge

This repository contains a minimal web service and infrastructure as code to satisfy the Particle41 DevOps evaluation. The service returns the current timestamp and the caller's IP in JSON, is containerized for Docker, and can be deployed to AWS with Terraform-managed EKS resources.

## Repository layout
- `app/` – SimpleTimeService source code (NestJS/TypeScript), Dockerfile, and app-specific documentation.
- `terraform/` – Terraform configuration for the AWS VPC, EKS cluster, and Kubernetes deployment of the container.

## What still needs attention
- **Container image publication**: update `terraform/app_image` (or `terraform.tfvars`) to point to the tag you push to your public registry.
- **Remote Terraform backend**: the backend is configured for an S3 bucket named `terraform-p41`. Create that bucket (or update `versions.tf`) before running Terraform so state can be written successfully.
- **AWS credentials**: ensure your AWS CLI profile/variables are configured with sufficient permissions to create VPC, EKS, ALB, and related IAM roles.

## Prerequisites
- [Node.js 20+](https://nodejs.org/en/download) for local development.
- [Docker](https://docs.docker.com/get-docker/) for building and running the container image.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with an account that allows VPC/EKS/ALB creation.
- [Terraform 1.0+](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed locally.

## Running the service locally
1. Install dependencies and start the server:
   ```bash
   cd app
   npm install
   PORT=3002 npm run start:dev
   ```
2. Call the root endpoint:
   ```bash
   curl http://localhost:3002/
   ```
   You should see a JSON payload containing `timestamp` and `ip`.

## Build and run the Docker image
1. Build the image:
   ```bash
   cd app
   docker build -t your-dockerhub-username/particle41:latest .
   ```
2. Run the image as a non-root user (the Dockerfile already sets this up):
   ```bash
   docker run -p 3002:3002 -e PORT=3002 your-dockerhub-username/particle41:latest
   ```
3. Push to your public registry (Docker Hub example):
   ```bash
   docker push your-dockerhub-username/particle41:latest
   ```
   Update `terraform/terraform.tfvars` with the pushed tag for the EKS deployment.

## Deploying to AWS with Terraform
1. Configure deployment settings:
   ```bash
   cd terraform
   # edit terraform.tfvars to set app_image to your pushed image and adjust region or CIDR if desired
   ```
2. Initialize providers and modules:
   ```bash
   terraform init
   ```
3. Review the plan and then apply:
   ```bash
   terraform plan
   terraform apply
   ```
   Terraform will provision the VPC with public/private subnets, EKS cluster, ALB ingress controller, and deploy the SimpleTimeService pods in the private subnets.

## Accessing the service
After `terraform apply` completes, inspect the created Kubernetes ingress or AWS ALB DNS name from the Terraform output. Send a request to `/` to verify the timestamp/IP JSON response.

## Cleanup
Destroy the infrastructure when finished to avoid ongoing costs:
```bash
cd terraform
terraform destroy
```
