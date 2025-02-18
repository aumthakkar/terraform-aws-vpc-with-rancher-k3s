
# === root/variables.tf === 

variable "access_ip" {
  type = string
}

variable "dbname" {
  type = string
}

variable "dbuser" {
  type = string

  sensitive = true
}

variable "dbpass" {
  type = string

  sensitive = true
}

variable "private_key_path" {}