variable "name" {
  description = "Application name used for tagging and resource names."
  type        = string
  default     = "Particle41"
}

variable "org_short_name" {
  description = "Short prefix used in cluster and workload naming."
  type        = string
  default     = "p41"
}

variable "environment" {
  description = "Deployment environment identifier."
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use for subnets."
  type        = number
  default     = 2
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.33"
}

variable "app_image" {
  description = "Container image for the SimpleTimeService deployment."
  type        = string
  default     = "sarveshacharya/particle41:latest"
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 3002
}

variable "replicas" {
  description = "Number of pod replicas for the application deployment."
  type        = number
  default     = 2
}
