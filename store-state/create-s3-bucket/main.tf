terraform {
	backend "s3" {
		bucket = "superorbital-discover12-tfstate"
		key    = "root.tfstate"
		encrypt = true
	}
}

provider "aws" {
	version = "~> 1.30"
}

resource "aws_s3_bucket" "tfstate_store" {
	bucket = "superorbital-discover12-tfstate"
	acl    = "private"
	force_destroy = true

	versioning {
		enabled = true
	}

	logging {
		target_bucket = "${aws_s3_bucket.logs.id}"
		target_prefix = "logs/"
	}
}

resource "aws_s3_bucket" "logs" {
	bucket = "superorbital-discover12-tfstate-logs"
	acl    = "log-delivery-write"
}

output "public_ip" {
	value = "8.8.8.8"
}
