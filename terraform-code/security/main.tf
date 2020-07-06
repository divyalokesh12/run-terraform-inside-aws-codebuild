variable "vpc_id"{}
variable "env" {}

resource "aws_security_group" "CONVEYUIInstanceSecurityGroup" {
  name = "CONVEYUIInstanceSecurityGroup"
  vpc_id = "${var.vpc_id}"

  # SSH access from the VPC
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 # WEB access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags = {
   Name = "${format("CONVEYUI-EC2-SG-%s", upper(var.env))}"
}

} 

resource "aws_security_group" "CONVEYTomcatInstanceSecurityGroup" {
  name = "CONVEYTomcatInstanceSecurityGroup"
  vpc_id = "${var.vpc_id}"

  # SSH access from the VPC
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 10005
    to_port     = 10005
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 10009
    to_port     = 10009
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 10006
    to_port     = 10006
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "${format("CONVEYTomcat-EC2-SG-%s", upper(var.env))}"
}

}

resource "aws_security_group" "CONVEYELBSecurityGroup" {
  name = "CONVEYELBSecurityGroup"
  vpc_id = "${var.vpc_id}"

 
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags = {
   Name = "${format("CONVEYApp-ELB-SG-%s", upper(var.env))}"
}

}

resource "aws_security_group" "internalCONVEYELBSecurityGroup" {
  name = "internalCONVEYELBSecurityGroup"
  vpc_id = "${var.vpc_id}"

   ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] #defined ip to be updated
  }

 tags = {
   Name = "${format("CONVEYApp-ELB-SG-%s", upper(var.env))}"
}



}
output "CONVEYUIInstanceSecurityGroup-out" {
  value = "${aws_security_group.CONVEYUIInstanceSecurityGroup.id}"
  }
output "CONVEYTomcatInstanceSecurityGroup-out" {
  value = "${aws_security_group.CONVEYTomcatInstanceSecurityGroup.id}"
  }
output "CONVEYELBSecurityGroup-out" {
  value = "${aws_security_group.CONVEYELBSecurityGroup.id}"
  }
output "internalCONVEYELBSecurityGroup-out" {
  value = "${aws_security_group.internalCONVEYELBSecurityGroup.id}"
  }  

