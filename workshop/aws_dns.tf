resource "aws_route53_zone" "web_instance" {
  name = "${var.username}.workshop.internal"
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  comment = "My Awesome internal zone"
}