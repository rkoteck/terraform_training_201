# Lab: Multi-provider

This lab demonstrates how several providers can be used together.

- Task 1: Provision an image with open access
- Task 2: Use the GitHub provider to constrain access to only GitHub Pages IPs

## Prerequisites

Double check that the `terraform` binary and your AWS environment variables have been properly configured for you:

    $ which terraform
    /home/discover0/bin/Linux/terraform

    $ env | grep AWS
    AWS_SECRET_ACCESS_KEY=PSD...
    AWS_DEFAULT_REGION=us-west-2
    AWS_ACCESS_KEY_ID=AKI...

## Task 1: Provision an image with open access

For this task, you'll generate a GitHub access token, clone demo code for this lab, and provision infrastructure without any constraints. This will show that the security group has no restrictions to start with (you'll lock it down in the next step).

### Step 1.1: Create a GitHub access token

Go to your [GitHub Settings Page](https://github.com/settings/tokens) and find "Developer Settings." Click the "Personal access tokens" menu item. Click the "Generate new token" button.

For the "Token Description", enter a name such as "Terraform 201 Token". You don't need to select any scopes. Scroll to the bottom and click the green "Generate Token" button.

Copy the resulting token and save it to a secure location.

### Step 1.2: Examine the demo code

Examine the `main.tf` file.  It's been pre-populated with a multi-provider configuration.

### Step 1.3: Configure the initial code

Configure the variables so the code can run. You'll need to copy your `github_token` to `terraform.tfvars`. You may need to create this file from scratch.

    # terraform.tfvars
    github_token="abcdef"

### Step 1.4: Note the configuration of the GitHub provider

Open `main.tf` and look for `provider "github"` within the first 15 lines of the file.

Just as we have configured the `aws` provider, we can provide credentials for other APIs.

See the [GitHub Provider](https://www.terraform.io/docs/providers/github/index.html) for details on required configuration settings and available data sources and other resources that can be created.

    # Configure the GitHub Provider
    provider "github" {
      token        = "${var.github_token}"
      organization = "placeholder"
    }

In order to simplify this demo, we use the word `placeholder` as the organization name. If you are creating resources which apply to a specific organization, you must configure it correctly here.

Also note the line where we use a data source to query `github_ip_ranges`. This gives us access to values such as all the IP address ranges of [GitHub Pages](https://pages.github.com/) instances or other parts of the GitHub infrastructure.

    data "github_ip_ranges" "test" {}

Later on, you'll use values from this data source to configure an AWS EC2 security group.

### Step 1.5: Initialize and apply the configuration

Initialize and apply the configuration.

    $ terraform init
    $ terraform apply

You'll see that a `provisioner` step successfully pings both a GitHub IP address and `hashicorp.com`.

    aws_instance.example (remote-exec): PING 192.30.252.153 (192.30.252.153) 56(84) bytes of data.
    aws_instance.example (remote-exec): 64 bytes from 192.30.252.153: icmp_seq=1 ttl=43 time=75.0 ms

    aws_instance.example (remote-exec): PING hashicorp.com (151.101.193.183) 56(84) bytes of data.
    aws_instance.example (remote-exec): 64 bytes from 151.101.193.183: icmp_seq=1 ttl=46 time=19.6 ms

In the next task, you'll lock down the instance so it can only communicate to the GitHub IP address, not the `hashicorp.com` IP address.

But first, destroy the instance so we can start fresh in the next task.

    $ terraform destroy -force

## Task 2: Use the GitHub provider to constrain access to only GitHub Pages IPs

In this task, you'll use data collected from the GitHub API to configure the EC2 security group. You'll restrict `egress` (outgoing) to only allow access to IP addresses that represent GitHub Pages resources.

### Step 2.1: Reconfigure the security group

The original code defined a `cidr_blocks` argument that allowed the instance to connect to all IP address ranges (`0.0.0.0/0`).

In the `egress` (NOT `ingress`) definition: Delete the `0.0.0.0/0` value and replace it with one that restricts egress to only the values retrieved from the GitHub API (`data.github_ip_ranges.test.pages`).

This will restrict outgoing traffic to only allow communication to IP addresses associated with the GitHub Pages service.

### Step 2.2: Provision and observe (intended) failure

Now mark the instance as tainted and provision the infrastructure as before. The `ping` to the first IP address will succeed since it is a GitHub Pages IP address. The second `ping` to `hashicorp.com` will fail since it is no longer allowed by the security group setting.

    $ terraform taint aws_instance.example
    The resource aws_instance.example in the module root has been marked as tainted!

    $ terraform apply

    ...
    aws_instance.example (remote-exec): PING 192.30.252.153 (192.30.252.153) 56(84) bytes of data.
    aws_instance.example (remote-exec): 64 bytes from 192.30.252.153: icmp_seq=1 ttl=43 time=75.4 ms

    aws_instance.example (remote-exec): PING hashicorp.com (151.101.1.183) 56(84) bytes of data.
    aws_instance.example: Still creating... (40s elapsed)

    Error: Error applying plan:

    1 error(s) occurred:

    * aws_instance.example: error executing "/tmp/terraform_614419066.sh": Process exited with status 1

In order to understand this further, read the lines in the `aws_instance` resource which define a `remote-exec` `provisioner` which sends a `ping` to both GitHub and HashiCorp.

#### Critical Thinking:

1. Why did we have to mark the instance as tainted before running `terraform apply`?  What would have happened if we hadn't?
2. What happens if GitHub changes the IP addresses for their Pages service?  What ideas do you have for dealing with this?

### Step 2.3: Destroy

Clean up after yourself by destroying the infrastructure created in this lab.

    $ terraform destroy -auto-approve
