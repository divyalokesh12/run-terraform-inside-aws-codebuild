provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Module to create Security Group
module "security" {
source = "./modules/security"
vpc_id = "${var.vpc_id}"
env    = "${var.env}"
} 


 
#Module to create Instance
module "instance" {
source = "./modules/instance"
vpc_id = "${var.vpc_id}"
key_pair ="${var.key_pair}"
ami_id ="${var.ami_id}"
subnet_public="${var.subnet_public}"
subnet_private="${var.subnet_private}"
UI_instance_type="${var.UI_instance_type}"
Tomcat_instance_type="${var.Tomcat_instance_type}"
ConveyTomcatInstanceSG_id = "${module.security.CONVEYTomcatInstanceSecurityGroup-out}"
ConveyUIInstanceSG_id = "${module.security.CONVEYUIInstanceSecurityGroup-out}"
env = "${var.env}"
Backend_instance_count ="${var.Backend_instance_count}"
Web_instance_count ="${var.Web_instance_count}"
}

#Module to create Load Balancer
module "LB" {
source = "./modules/LB"
vpc_id = "${var.vpc_id}"
env = "${var.env}"
WebInstances_id = "${module.instance.WebInstances_id-out}"
BackendInstances_id = "${module.instance.BackendInstances_id-out}"
CONVEYELBSG_id = "${module.security.CONVEYELBSecurityGroup-out}"
internalCONVEYELBSG_id = "${module.security.internalCONVEYELBSecurityGroup-out}"
Web_instance_count ="${var.Web_instance_count}"
Backend_instance_count ="${var.Backend_instance_count}"
}

