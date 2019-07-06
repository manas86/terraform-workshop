data "template_file" "policy_scaling_node_instance" {
  template = "${file("${path.module}/resources/policy-scaling-node-instance.json")}"
  # template = file("${path.module}/resources/policy-scaling-node-instance.json")

}

data "template_file" "policy_ec2_scaling_node_instance" {
  template = "${file("${path.module}/resources/policy-assume-role-ec2.json")}"
  # template = file("${path.module}/resources/policy-scaling-node-instance.json")

}

resource "aws_iam_role" "scaling_node_instance" {
  name = "workshop-main-scaling-node-instance-role-${var.username}"
  assume_role_policy = "${data.template_file.policy_ec2_scaling_node_instance.rendered}"
}

resource "aws_iam_instance_profile" "scaling_node_instance_profile" {
  name = "workshop-main-scaling-node-instance-profile-${var.username}"
  role = aws_iam_role.scaling_node_instance.id
}

resource "aws_iam_role_policy" "scaling_node_instance_policy" {
  name = "workshop-main-scaling_node-role-policy-${var.username}"
  role = aws_iam_role.scaling_node_instance.name
  policy = "${data.template_file.policy_scaling_node_instance.rendered}"
}