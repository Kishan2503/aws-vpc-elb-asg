resource "aws_vpc" "devvpc" {
    cidr_block = "${var.main_cidr}"
    enable_dns_support = true #gives you an internal domain name
    enable_dns_hostnames = true #gives you an internal host name
    enable_classiclink = false
    #instance_tenancy = default    
    
    tags = {
        Name = "devvpc"
    }
}

resource "aws_subnet" "dev-subnet-public-1" {
    vpc_id = "${aws_vpc.devvpc.id}  "
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true //it makes this a public subnet
    availability_zone = "us-west-2a"
    tags = {
        Name = "dev-subnet-public-1"
    }
}

resource "aws_subnet" "dev-subnet-public-2" {
    vpc_id = "${aws_vpc.devvpc.id}  "
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true //it makes this a public subnet
    availability_zone = "us-west-2b"
    tags = {
        Name = "dev-subnet-public-2"
    }
}

resource "aws_subnet" "dev-subnet-private-1" {
    vpc_id = "${aws_vpc.devvpc.id}"
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-west-2a"
    tags = {
        Name = "dev-subnet-private-1"
    }
}

resource "aws_subnet" "dev-subnet-private-2" {
    vpc_id = "${aws_vpc.devvpc.id}"
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-west-2b"
    tags = {
        Name = "dev-subnet-private-2"
    }
}

resource "aws_internet_gateway" "dev-igw" {
    vpc_id = "${aws_vpc.devvpc.id}"
    tags = {
        Name = "dev-igw"
    }
}

resource "aws_eip" "Dev-Nat-Gateway-EIP" {
  vpc = true
}

resource "aws_nat_gateway" "dev-ngw" {
  allocation_id = "${aws_eip.Dev-Nat-Gateway-EIP.id}"
  subnet_id     = "${aws_subnet.dev-subnet-public-1.id}"

  tags = {
    Name = "dev NAT gw"
  }
}

resource "aws_route_table" "dev-public-route" {
    vpc_id = "${aws_vpc.devvpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.dev-igw.id}" 
    }
    
    tags = {
        Name = "dev-public-route"
    }
}

resource "aws_route_table" "dev-private-route" {
    vpc_id = "${aws_vpc.devvpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_nat_gateway.dev-ngw.id}" 
    }
    
    tags = {
        Name = "dev-private-route"
    }
}

resource "aws_route_table_association" "dev-route-public-1"{
    subnet_id = "${aws_subnet.dev-subnet-public-1.id}"
    route_table_id = "${aws_route_table.dev-public-route.id}"
}

resource "aws_route_table_association" "dev-route-public-2"{
    subnet_id = "${aws_subnet.dev-subnet-public-2.id}"
    route_table_id = "${aws_route_table.dev-public-route.id}"
}

resource "aws_route_table_association" "dev-route-private-1"{
    subnet_id = "${aws_subnet.dev-subnet-private-1.id}"
    route_table_id = "${aws_route_table.dev-private-route.id}"
}

resource "aws_route_table_association" "dev-route-private-2"{
    subnet_id = "${aws_subnet.dev-subnet-private-2.id}"
    route_table_id = "${aws_route_table.dev-private-route.id}"
}

resource "aws_security_group" "ssh-allowed" {
    vpc_id = "${aws_vpc.devvpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "ssh-allowed"
    }
}

resource "aws_security_group" "only-allow-loadbalancer" {
    vpc_id = "${aws_vpc.devvpc.id}"
    
    # Needed to install web server package into instances
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["10.0.1.0/24"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    # ingress {
    #     from_port = 443
    #     to_port = 443
    #     protocol = "tcp"
    #     cidr_blocks = ["10.0.1.0/24"]
    # }
    tags = {
        Name = "only-allow-loadbalancer"
    }
}

resource "aws_security_group" "loadbalancer-public-access" {
    vpc_id = "${aws_vpc.devvpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    tags = {
        Name = "loadbalancer-public-access"
    }
}