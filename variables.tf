variable "pvt_key" {
  type        = string
  description = "My public key"
}

variable "rebrain_key" {
  type        = string
  description = "rebrain public key"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}
variable "host_name" {
  type        = string  
  description = "A records name"
}

variable "yc_image_family" {
  description = "family"
  default     = "ubuntu-2004-lts"
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
}

variable "private_key" {
  default     = "/home/chekist333/.ssh/alipatnikov2"
  description = "Path to private key file"
}

variable "labels_devops" {
  type        = string
  description = "My labels subject"
}

variable "labels_email" {
  type        = string
  description = "My labels subject"
}

variable "aws_zone" {
  type        = string
  description = "aws_zone"
}




