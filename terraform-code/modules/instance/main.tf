variable "vpc_id" { }
variable "Backend_instance_count" {}
variable "Web_instance_count" {}
variable "env" {}
#variable "service"{}
variable "ConveyTomcatInstanceSG_id" {}
variable "ConveyUIInstanceSG_id" {}
variable "key_pair" {}
variable "ami_id"{}
variable "UI_instance_type"{}
variable "Tomcat_instance_type"{}
#variable "Role_EC2FullAccess"{}
variable "subnet_public"{}
variable "subnet_private"{}


resource "aws_instance" "Web_instance" {
  count                  ="${var.Web_instance_count}"
  ami                    ="${var.ami_id}"
  instance_type          = "${var.UI_instance_type}"
  subnet_id		 = "${element(var.subnet_public,count.index)}"
  key_name               = "${var.key_pair}"
  associate_public_ip_address = true
  vpc_security_group_ids =["${var.ConveyUIInstanceSG_id}"]
  disable_api_termination = true
/*  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_type           = "gp2"
    volume_size           = 20
    encrypted             = true
  } */

  /*iam_instance_profile {
    name = "${var.Role_EC2FullAccess}"
  }*/
#  instance_initiated_shutdown_behavior = "stop"
#  monitoring  = true
#  tenancy  = "default"
  tags = {
   Name = "${format("ev-u-convey-static-%d", count.index)}"
   Environment      = "${format("%s", upper(var.env))}"
   Pod = "production"
   Function = "UI"
}
}


resource "aws_instance" "Backend_instance" {
  count                  ="${var.Backend_instance_count}"
  ami                    ="${var.ami_id}"
  instance_type          = "${var.Tomcat_instance_type}"
  subnet_id              = "${element(var.subnet_private,count.index)}"
  key_name               = "${var.key_pair}"
  associate_public_ip_address = false
  vpc_security_group_ids =[ "${var.ConveyTomcatInstanceSG_id}"]
  disable_api_termination = true
  tags = {
   Name = "${format("ev-u-convey-Tomcat-%d", count.index)}"
   Environment      = "${format("%s", upper(var.env))}"
   Pod = "production"
   Function = "Tomcat"
}
}

output "WebInstances_id-out" {
value = "${join(",",aws_instance.Web_instance.*.id)}"
}
output "BackendInstances_id-out" {
value = "${join(",",aws_instance.Backend_instance.*.id)}"
}
