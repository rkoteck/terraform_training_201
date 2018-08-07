provider "aws" {}

resource "aws_security_group" "training" {
  name_prefix = "demo-modified"

	lifecycle {
		create_before_destroy = true
		# prevent_destroy = true
	}

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-e474db9c"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.training.id}"]

  tags {
    Name = "demo-simple-instance"
  }
}
