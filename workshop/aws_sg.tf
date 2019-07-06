resource "aws_security_group" "my-inbound-80" {
  name = "workshop-rest-node-${var.username}-inbound"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"

    # You always have to supply a cidr.
    # In this case the entire internet.
    # It is always recommended to have the cidr
    # as restricted as possible in a real-life situation.
    # cidr_blocks = [
    #  "0.0.0.0/0"
    # ]

    security_groups = [aws_security_group.main-node.id]
  }
}