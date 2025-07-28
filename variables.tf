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

variable "availability_zones" {
  description = "Lista de Zonas de Disponibilidad a usar"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnet_cidrs" {
  description = "Lista de rangos de IPs para las subredes publicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Lista de rangos de IPs para las subredes privadas"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
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