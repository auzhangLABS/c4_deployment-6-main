## specific the provider
provider "aws" {
  alias = "us-east-1"  
  region =  "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_access_key

}

provider "aws" {
  alias = "us-west-2"
  region =  "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_access_key
}

#creating a VPC for east
resource "aws_vpc" "vpceast" {
    provider = aws.us-east-1
    cidr_block = "12.0.0.0/16"
    tags = {
        Name = "deployment6-vpc-east"
    }
}

#creating a VPC for west
resource "aws_vpc" "vpcwest" {
    provider = aws.us-west-2
    cidr_block = "13.0.0.0/16"

    tags = {
        Name = "deployment6-vpc-west"
    }
}

#creating a Public Subnet east 1
resource "aws_subnet" "pubeast1"{
    provider = aws.us-east-1
    vpc_id =  aws_vpc.vpceast.id
    cidr_block = "12.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "publicSubnet01"
    }
}

#creating a Public Subnet east 2
resource "aws_subnet" "pubeast2"{
    provider = aws.us-east-1
    vpc_id =  aws_vpc.vpceast.id
    cidr_block = "12.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "publicSubnet02"
    }
}

#creating a Public Subnet west 1
resource "aws_subnet" "pubwest1"{
    provider = aws.us-west-2
    vpc_id =  aws_vpc.vpcwest.id
    cidr_block = "13.0.1.0/24"
    availability_zone = "us-west-2a"
    tags = {
        Name = "publicSubnet03"
    }
}


#creating a Public Subnet west 1
resource "aws_subnet" "pubwest2"{
    provider = aws.us-west-2
    vpc_id =  aws_vpc.vpcwest.id
    cidr_block = "13.0.2.0/24"
    availability_zone = "us-west-2b"
    tags = {
        Name = "publicSubnet04"
    }
}

# creating security group for east 
resource "aws_security_group" "d6_sg_east" {
    provider = aws.us-east-1
    vpc_id = aws_vpc.vpceast.id
    name = "d6_sg"
    description = "tcp protocol for D6" 

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        "Name" : "HTTPAcessSG_east"
        "Terraform" : "true"
    }
}


# creating security group for west
resource "aws_security_group" "d6_sg_west" {
    provider = aws.us-west-2
    vpc_id = aws_vpc.vpcwest.id    
    name = "d6_sg"
    description = "tcp protocol for D6" 

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        "Name" : "HTTPAcessSG_west"
        "Terraform" : "true"
    }
}

# create instance
resource "aws_instance" "appeast1" {
  provider = aws.us-east-1
  ami = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.d6_sg_east.id]
  subnet_id = "${aws_subnet.pubeast1.id}"

  user_data = "${file("deploypython.sh")}"

  tags = {
    "Name" : "applicationServer01-east"
  }

}

resource "aws_instance" "appeast2" {
  provider = aws.us-east-1
  ami = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.d6_sg_east.id]
  subnet_id = "${aws_subnet.pubeast2.id}"

  user_data = "${file("deploypython.sh")}"

  tags = {
    "Name" : "applicationServer02-east"
  }

}

resource "aws_instance" "appwest1" {
  provider = aws.us-west-2
  ami = "ami-0efcece6bed30fd98"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.d6_sg_west.id]
  subnet_id = "${aws_subnet.pubwest1.id}"

  user_data = "${file("deploypython.sh")}"

  tags = {
    "Name" : "applicationServer01-west"
  }

}

resource "aws_instance" "appwest2" {
  provider = aws.us-west-2
  ami = "ami-0efcece6bed30fd98"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.d6_sg_west.id]
  subnet_id = "${aws_subnet.pubwest2.id}"

  user_data = "${file("deploypython.sh")}"

  tags = {
    "Name" : "applicationServer02-west"
  }

}

# creating route table for east
resource "aws_route" "routetableeast" {
    provider = aws.us-east-1
    route_table_id = aws_vpc.vpceast.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_east.id
}

#creating route table for west
resource "aws_route" "routetablewest" {
    provider = aws.us-west-2
    route_table_id = aws_vpc.vpcwest.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_west.id
}


# creating internet gateway for east 
resource "aws_internet_gateway" "igw_east" {
    provider =  aws.us-east-1
    vpc_id = aws_vpc.vpceast.id

    tags = {
      Name = "deployment6-internetgateway-east"
    }
}

# creating internet gateway for west 
resource "aws_internet_gateway" "igw_west" {
    provider = aws.us-west-2
    vpc_id = aws_vpc.vpcwest.id

    tags = {
      Name = "deployment6-internetgateway-west"
    }
}
