variable "vpc_id" { }
variable "Web_instance_count" {}
variable "Backend_instance_count" {}
variable "CONVEYELBSG_id" {}
variable "internalCONVEYELBSG_id" {}
variable "WebInstances_id" {}
variable "BackendInstances_id" {}
variable "env" {}

data "aws_subnet_ids" "private_ids" {
  vpc_id = "${var.vpc_id}"
  filter {
    name   = "tag:Name"
    values = ["subnet-pri*"]
  }
}
data "aws_subnet_ids" "public_ids" {
  vpc_id = "${var.vpc_id}"
  filter {
    name   = "tag:Name"
    values = ["subnet-pub*"]
  }
}

resource "aws_lb_target_group" "CONVEYwebTG" {
  name     = "CONVEYwebTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "instance"
  deregistration_delay = 20
  health_check {
    protocol            = "HTTP"
    path                = "/f5-status.html"
    timeout             = 3
    healthy_threshold   = 5
    unhealthy_threshold = 3
    interval            = 9
    matcher             = "200"
}
}

resource "aws_alb_target_group_attachment" "CONVEYwebTG" {
  count    = "${var.Web_instance_count}"
  target_group_arn = "${aws_lb_target_group.CONVEYwebTG.arn}"
  target_id = element(split(",",var.WebInstances_id),count.index)
  lifecycle {
    ignore_changes = ["target_id"]
  }
}

resource "aws_lb_target_group" "CONVEYserviceTG" {
  name     = "CONVEYserviceTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "instance"
  deregistration_delay = 20
  health_check {
    protocol            = "HTTP"
    path                = "/convey-service/"
    timeout             = 3
    healthy_threshold   = 5
    unhealthy_threshold = 3
    interval            = 9
    matcher             = "200"
}
}

resource "aws_alb_target_group_attachment" "CONVEYserviceTG" {
  count    = "${var.Backend_instance_count}"
  target_group_arn = "${aws_lb_target_group.CONVEYserviceTG.arn}"
  target_id = element(split(",",var.BackendInstances_id),count.index)
  lifecycle {
    ignore_changes = ["target_id"]
  }
}

resource "aws_lb_target_group" "CONVEYAPIserviceTG" {
  name     = "CONVEYAPIserviceTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "instance"
  deregistration_delay = 20
  health_check {
    protocol            = "HTTP"
    path                = "/convey-service/"
    timeout             = 3
    healthy_threshold   = 5
    unhealthy_threshold = 3
    interval            = 9
    matcher             = "200"
}
}

resource "aws_alb_target_group_attachment" "CONVEYAPIserviceTG" {
  count    = "${var.Backend_instance_count}"
  target_group_arn = "${aws_lb_target_group.CONVEYAPIserviceTG.arn}"
  target_id = element(split(",",var.BackendInstances_id),count.index)
  lifecycle {
    ignore_changes = ["target_id"]
  }
}

resource "aws_lb_target_group" "CONVEYAPIconfigserviceTG" {
  name     = "CONVEYAPIconfigserviceTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "instance"
  deregistration_delay = 20
  health_check {
    protocol            = "HTTP"
    path                = "/convey-service/"
    timeout             = 3
    healthy_threshold   = 5
    unhealthy_threshold = 3
    interval            = 9
    matcher             = "200"
}
}


resource "aws_alb_target_group_attachment" "CONVEYAPIconfigserviceTG" {
  count    = "${var.Backend_instance_count}"
  target_group_arn = "${aws_lb_target_group.CONVEYAPIconfigserviceTG.arn}"
  target_id = element(split(",",var.BackendInstances_id),count.index)
  lifecycle {
    ignore_changes = ["target_id"]
  }
}

resource "aws_alb" "conveyLoadBalancer" {
name            = "conveyLoadBalancer"
internal        = false
security_groups = ["${var.CONVEYELBSG_id}"]
subnets         = data.aws_subnet_ids.public_ids.ids
/*access_logs {
    bucket  = "${aws_s3_bucket.lb_logs.bucket}"
    prefix  = "test-lb"
    enabled = true
  }*/
enable_deletion_protection       = false
tags          = {
    Name     = "${format("CONVEY-convey-%s", upper(var.env))}"
    }
}

resource "aws_alb_listener" "conveyHTTPListener" {
#count             = "1"
load_balancer_arn = "${aws_alb.conveyLoadBalancer.arn}"
port              = "80"
protocol          = "HTTP"
#ssl_policy        = "ELBSecurityPolicy-2015-05"
#certificate_arn   = "${var.ssl_certificate_arn}"
default_action {
#target_group_arn = "${element(aws_lb_target_group.test.*.arn, 0)}"
  type = "redirect"

  redirect {
    host         = "#{host}"
    path        = "/#{path}"
    port        = "443"
    protocol    = "HTTPS"
    query       = "#{query}"
    status_code = "HTTP_301"
    }
}
}


resource "aws_alb" "apiconveyLoadBalancer" {
name            = "apiconveyLoadBalancer"
internal        = false
security_groups = ["${var.CONVEYELBSG_id}"]
subnets         = data.aws_subnet_ids.public_ids.ids
/*access_logs {
    bucket  = "${aws_s3_bucket.lb_logs.bucket}"
    prefix  = "test-lb"
    enabled = true
  }*/
enable_deletion_protection       = false
tags          = {
    Name     = "${format("CONVEY-api-%s", upper(var.env))}"
    }
}


resource "aws_alb_listener" "apiconveyHTTPListener" {
#count             = "1"
load_balancer_arn = "${aws_alb.apiconveyLoadBalancer.arn}"
port              = "80"
protocol          = "HTTP"
#ssl_policy        = "ELBSecurityPolicy-2015-05"
#certificate_arn   = "${var.ssl_certificate_arn}"
default_action {
#target_group_arn = "${element(aws_lb_target_group.test.*.arn, 0)}"
  type = "redirect"

  redirect {
    host         = "#{host}"
    path        = "/#{path}"
    port        = "443"
    protocol    = "HTTPS"
    query       = "#{query}"
    status_code = "HTTP_301"
    }
}
}


resource "aws_alb" "internalconveyLoadBalancer" {
name            = "internalconveyLoadBalancer"
internal        = true
security_groups = ["${var.internalCONVEYELBSG_id}"]
subnets         = data.aws_subnet_ids.public_ids.ids
/*access_logs {
    bucket  = "${aws_s3_bucket.lb_logs.bucket}"
    prefix  = "test-lb"
    enabled = true
  }*/
enable_deletion_protection       = false
tags          = {
    Name     = "${format("CONVEY-internal-%s", upper(var.env))}"
    }
}

resource "aws_alb_listener" "internalconveyHTTPListener" {
#count             = "1"
load_balancer_arn = "${aws_alb.internalconveyLoadBalancer.arn}"
port              = "80"
protocol          = "HTTP"
#ssl_policy        = "ELBSecurityPolicy-2015-05"
#certificate_arn   = "${var.ssl_certificate_arn}"
default_action {
#target_group_arn = "${element(aws_lb_target_group.test.*.arn, 0)}"
  type = "fixed-response"

  fixed_response {
    content_type = "text/plain"
    status_code  = "404"
    }
}
}

resource "aws_alb_listener_rule" "webRootListenerRule" {
listener_arn               = "${aws_alb_listener.internalconveyHTTPListener.arn}"
priority                   =  100
action {
    type             = "forward"
    target_group_arn           = "${element(aws_lb_target_group.CONVEYserviceTG.*.arn, 0)}"
  }
 condition {
    path_pattern {
      values = ["/ci-service/*"]
    }
  }
}
