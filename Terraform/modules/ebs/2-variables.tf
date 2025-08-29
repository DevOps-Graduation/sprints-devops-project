variable "availability_zone" {
  type = string
}

variable "size" {
  type    = number
  default = 1
}

variable "volume_type" {
  type    = string
  default = "gp2"
}

variable "name" {
  type    = string
  default = "db-ebs-volume"
}
