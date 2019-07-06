data "aws_ami" "scaling" {
  owners = [
    "699987334313"
  ]
  most_recent = true

  filter {
    name = "name"
    values = [
      "scaling-node-*"
    ]
  }
}

resource "aws_launch_configuration" "scaling_id" {
  name_prefix = "${var.username}"
  image_id = data.aws_ami.scaling.image_id
  instance_type = "t2.micro"

  iam_instance_profile = "${aws_iam_instance_profile.scaling_node_instance_profile.id}"

  security_groups = [
    aws_security_group.outbound.id
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "scaling_group" {
  name_prefix = "${var.username}-${aws_launch_configuration.scaling_id.name}"
  availability_zones = data.aws_availability_zones.available.names
  desired_capacity = 2
  max_size = 2
  min_size = 2
  launch_configuration = aws_launch_configuration.scaling_id.name
  vpc_zone_identifier = module.vpc.public_subnets

  tag {
    key = "Name"
    value = "${var.username}-scaling-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}