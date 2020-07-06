variable "access_key" {}
variable "secret_key" {}
variable "region" {}
#variable "Role_EC2FullAccess"{}
variable "vpc_id" { }
variable "env" { }
variable "Web_instance_count" {}
variable "Backend_instance_count" {}
variable "key_pair" {}
variable "ami_id"{}
variable "UI_instance_type"{}
variable "Tomcat_instance_type"{}
variable "subnet_public"{
 type = "list"
}
variable "subnet_private"{
 type = "list"
}
#variable "web_ins_count"{}
#variable "backend_ins_count"{}
