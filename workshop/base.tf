### BASE ###
# This is the environment provided to you at the beginning of the workshop.
# Do not fret if it all seems complicated, you do not have to understand it all for now.  :)
# Just in case, this file has been heavily documented for reference.


# We define a provider first, which for us will be AWS
# Note that there are not credentials here, by default it uses those available in your environment (e.g. AWS CLI)
provider "aws" {
  region = var.region
  access_key = var.aws_key
  secret_key = var.aws_secret
}

# This is a data resource, it provides data about the cloud environment
# In this case, it provides us with all the availability zones in our configured region
data "aws_availability_zones" "available" {
}

# When terraform finishes updating the environment it will output all outputs to the console.
# This one outputs our dashboard URL.
output "dashboard_url" {
  value = "http://${aws_eip.webserver.public_ip}"
}

# Another data resource, this finds the latest AMI we built which contains the Main Node dashboard.
data "aws_ami" "ubuntu" {
  owners = ["699987334313"]
  most_recent = true

  filter {
    name = "name"
    values = ["main-node-*"]
  }
}

# This is your elastic IP. When you have to redeploy your main node your IP will stay the name because of this :)
resource "aws_eip" "webserver" {
  instance = aws_instance.webserver.id
  vpc = true

  tags = {
    workshop_user = var.username
  }
}

### EC2 instance ###
# This will be your main node. See comments on properties for more information.
resource "aws_instance" "webserver" {

  # The AMI provided by the above data resource. This will be the latest bitnami node-11  AMI.
  ami = data.aws_ami.ubuntu.image_id
  # The instance type. t2.micro (which is in free tier) is more than enough for now.
  instance_type = "t2.micro"

  # These are the security groups to this instance. They open the all-closed default firewall of amazon.
  # Opened for now are the inbound 8080 port, and the instance is allowed to communicate outwards.
  vpc_security_group_ids = [
    aws_security_group.main-node.id,
    aws_security_group.outbound.id,
  ]
  # The VPC subnet this instance is in. Just the first for now.
  subnet_id = module.vpc.public_subnets[0]
  # The instance profile, which defines this the permissions of this instance in the AWS environment
  # Needed to populate your dashboard with progress data
  iam_instance_profile = aws_iam_instance_profile.webserver_instance_profile.name


  # Tags can be added to many resources. Names are quite useful for human identification of an AWS resource.
  # We include username so it is linkable to you directly
  tags = {
    workshop_user = var.username
    Name = "${var.username}-main-node"
  }
}

# This security group tells AWS that the instance to which this is linked is allowed to have traffic inbound on port 8080.
# Because of this you can access your dashboard!
resource "aws_security_group" "main-node" {
  name = "workshop-main-node-${var.username}-inbound"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"

    # You always have to supply a cidr. In this case the entire internet.
    # It is always recommended to have the cidr as restricted as possible in a real-life situation.
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    workshop_user = var.username
  }
}

# This security group tells AWS the instance is allowed to access the internet on any port
resource "aws_security_group" "outbound" {
  name = "workshop-main-node-${var.username}-outbound"
  description = "Allow to access the world"
  vpc_id = module.vpc.vpc_id
  # SSH access from anywhere
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    workshop_user = var.username
  }
}

### VPC ###
# VPCs are very hard to setup. It is often easier to use a module.
# So we did that here. If you want to know how VPCs work in-depth, ask someone from the workshop
module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name = "workshop-vpc-${var.username}"

  cidr = "10.2.0.0/16"
  private_subnets = [
    "10.2.1.0/24",
    "10.2.2.0/24"]
  public_subnets = [
    "10.2.101.0/24",
    "10.2.102.0/24"]
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    workshop_user = var.username
  }
}

### POLICIES ###
# These are the things required to craft an AWS instance role.
# We will explain this later in the workshop.
data "template_file" "policy_webserver" {
  template = file("${path.module}//resources/policy-webserver.json")
}

data "template_file" "policy_assume_role_ec2" {
  template = file("${path.module}//resources/policy-assume-role-ec2.json")
}

resource "aws_iam_role" "webserver_instance" {
  name = "workshop-main-node-instance-role-${var.username}"
  assume_role_policy = data.template_file.policy_assume_role_ec2.rendered
  tags = {
    workshop_user = var.username
  }
}

resource "aws_iam_instance_profile" "webserver_instance_profile" {
  name = "workshop-main-node-instance-profile-${var.username}"
  role = aws_iam_role.webserver_instance.id
}

resource "aws_iam_role_policy" "webserver_instance_policy" {
  name = "workshop-main-node-role-policy-${var.username}"
  role = aws_iam_role.webserver_instance.name
  policy = data.template_file.policy_webserver.rendered
}
