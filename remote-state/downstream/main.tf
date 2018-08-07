# downstream/main.tf
# Read state from another Terraform config's state
data "terraform_remote_state" "upstream" {
	backend = "local"
	config = {
		path = "../upstream/terraform.tfstate"
	}
}

output "upstream_public_ip" {
	value = "${data.terraform_remote_state.upstream.public_ip}"
}
