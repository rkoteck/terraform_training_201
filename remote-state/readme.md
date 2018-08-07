# Lab: Remote State

This lab demonstrates...

- Task 1:  Create a Terraform configuration that defines an output
- Task 2:  Read an output value from that project's state

## Prerequisites

This lab only requires the `terraform` command, which should have been installed for you:

~~~ console
$ which terraform
/home/discover0/bin/Linux/terraform
~~~

## Task 1: Create a Terraform configuration that defines an output

For this task, you'll create two Terraform configurations in two separate directories. One will read from the other (using state files).

### Step 1.1

In this step, you'll create a Terraform project on disk that does nothing but emit an output. It should emit `public_ip` which can be a hard-coded value (for simplicity).

The project should consist of a single file which can be named something like `upstream/main.tf`.

    $ mkdir upstream
    $ cd upstream
    $ vim main.tf

The contents of `main.tf` are a single output for `public_ip`. This is the entire contents of the file.

~~~ bash
# upstream/main.tf
output "public_ip" {
  value = "8.8.8.8"
}
~~~

### Step.1.2

Generate a state file for the project. Within that project, run `terraform init` and `apply`. You should see a `terraform.tfstate` file after running these commands.

Run the standard `terraform` commands within the `upstream` project.

    $ terraform init
    $ terraform apply

## Task 2: Read an output value from that project's state

### Step 2.1

Create a new Terraform configuration that uses a data source to read the configuration from the `upstream` project.

Create a second directory named `downstream`.

    $ cd ../
    $ mkdir downstream
    $ cd downstream
    $ vim main.tf

Define a `terraform_remote_state` data source that uses a `local` backend which points to the upstream project.

~~~ bash
# downstream/main.tf
# Read state from another Terraform config’s state
data "terraform_remote_state" "upstream" {
  backend = "local"
  config {
    path = "../upstream/terraform.tfstate"
  }
}
~~~

Initialize the downstream project with `init`.

    $ terraform init

### Step 2.2

Declare the `public_ip` as an `output`.

Within `downstream/main.tf`, define an output whose value is the `public_ip` from the data source you just defined.

~~~ bash
output "upstream_public_ip" {
  value = "${data.terraform_remote_state.upstream.public_ip}"
}
~~~

Finally, run `apply`. You should see the IP address you defined in the `upstream` configuration.

    $ terraform apply

    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

    Outputs:

    upstream_public_ip = 8.8.8.8
