variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "List of private subnet CIDR blocks for application layer"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "List of private subnet CIDR blocks for database layer"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}
