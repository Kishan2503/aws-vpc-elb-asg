module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  
  name = "dev-alb"

  load_balancer_type = "application"

  vpc_id             = "${aws_vpc.devvpc.id}"
  subnets            = ["${aws_subnet.dev-subnet-public-1.id}", "${aws_subnet.dev-subnet-public-2.id}"]
  security_groups    = ["${aws_security_group.loadbalancer-public-access.id}"]

  target_groups = [
    {
      name_prefix      = "server"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]


  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "dev"
  }
}