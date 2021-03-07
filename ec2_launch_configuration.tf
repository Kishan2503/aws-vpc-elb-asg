resource "aws_launch_configuration" "servers" {
  # Launch Configurations cannot be updated after creation with the AWS API.
  # In order to update a Launch Configuration, Terraform will destroy the
  # existing resource and create a replacement.
  #
  # We're only setting the name_prefix here,
  # Terraform will add a random string at the end to keep it unique.
  name_prefix = "server-"

  image_id                    = "ami-09c5e030f74651050"
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.only-allow-loadbalancer.id}"]
  key_name                    = "test"

  user_data = "${file("${path.module}/user-data.tpl")}"

  ebs_block_device {
    #count = 1
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "10"
    encrypted = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "servers" {
  # Force a redeployment when launch configuration changes.
  # This will reset the desired capacity if it was changed due to
  # autoscaling events.
  name = "${aws_launch_configuration.servers.name}-asg"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 3
  health_check_type    = "EC2"
  launch_configuration = "${aws_launch_configuration.servers.name}"
  vpc_zone_identifier  = ["${aws_subnet.dev-subnet-private-1.id}", "${aws_subnet.dev-subnet-private-2.id}"]
  #vpc_zone_identifier  = ["${aws_subnet.dev-subnet-public-1.id}", "${aws_subnet.dev-subnet-public-2.id}"]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
}