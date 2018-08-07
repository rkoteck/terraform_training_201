terraform {
	backend "s3" {
		bucket = "superorbital-discover12-tfstate"
		key = "use-state.tfstate"
		encrypt = true
	}
}

provider "aws" {
	version = "~> 1.30"
}

data "terraform_remote_state" "root" {
	backend = "s3"

	config {
		bucket = "superorbital-discover12-tfstate"
		key = "root.tfstate"
	}
}

output "public_ip" {
	value = "${data.terraform_remote_state.root.public_ip}"
}
