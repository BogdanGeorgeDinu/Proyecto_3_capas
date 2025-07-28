variable "region" {
  description = "Region de aws"
  type        = string
  default     = "eu-west-1"
}

variable "proyecto_bogdan" {
  description = "Proyecto Bogdan"
  type        = string
  default     = "webapp"
}

variable "vpc_cidr" {
  description = "Rango de IPs para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Rango de IPs para la subred publica"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Rango de IPs para la subred privada"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_username" {
  description = "Usuario para la base de datos"
  type        = string
  default     = "adminuser"
}

variable "db_password" {
  description = "Contraseña para la base de datos"
  type        = string
  sensitive   = true
}