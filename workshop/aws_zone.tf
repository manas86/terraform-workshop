resource "aws_route53_record" "web_instance_id" {
  zone_id = "Z3OWUVCWCSKBG4"
  name = "rest.${var.username}.workshop.internal"
  type = "A"
  ttl = "300"
  records = [
    "18.195.110.147"
  ]
}
