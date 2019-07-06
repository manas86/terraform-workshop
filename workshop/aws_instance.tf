data "aws_ami" "web_instance" {
  owners = ["699987334313"]
  most_recent = true

  filter {
    name = "name"
    values = ["rest-node-*"]
  }
}

resource "aws_instance" "web_instance" {
  ami = data.aws_ami.web_instance.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.my-inbound-80.id
    ]

  subnet_id = "${module.vpc.public_subnets[0]}"

tags = {
  Name = "${var.username}-rest-node"
  }
}