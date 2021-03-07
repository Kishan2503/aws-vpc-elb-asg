variable "main_cidr" {
  description = "main CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

# variable "subnet_cidrs_public" {
#   description = "Subnet CIDRs for public subnets"
#   default = ["10.0.1.0/24", "10.0.2.0/24"]
#   type = "list"
# }