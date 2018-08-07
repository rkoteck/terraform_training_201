# Lab: Store State Remotely on S3

This lab demonstrates...

- Task 1: Create an S3 bucket for state storage
- Task 2: Bootstrap the configuration to store its own state on S3
- Task 3: Create another Terraform config that reads from that state on S3

## Prerequisites

Double check that the `terraform` binary and your AWS environment variables have been properly configured for you:

    $ which terraform
    /home/discover0/bin/Linux/terraform

    $ env | grep AWS
    AWS_SECRET_ACCESS_KEY=PSD...
    AWS_DEFAULT_REGION=us-west-2
    AWS_ACCESS_KEY_ID=AKI...

## Task 1: Create an S3 bucket for state storage

In order to store state remotely, we need a place in which to store it. Amazon S3 is a supported storage medium and works well with Terraform.

For this task, you'll use the Terraform configuration API to create an S3 bucket with the required features enabled: logging, versioning, and optionally locking and at-rest encryption.

We'll also emit an output value so we can read it from another project later.

### Step 1.1:

Create an S3 bucket with versioning and logging enabled.  Let's define our `main.tf`:

    $ mkdir create-s3-bucket
    $ cd create-s3-bucket
    $ vim main.tf

Start by declaring the `aws` provider.

    provider "aws" {
      version    = "~> 1.30"
    }

Now, define a resource for the `aws_s3_bucket`. Give it a Terraform identifier such as `tfstate_store`.

The bucket needs a globally unique name within AWS.  Your account is allowed to create S3 buckets who's name starts with `superorbital-discoverN`.  Configure your bucket with such a name.  You'll also want to set it to `private` so only authorized accounts can read from it.

Terraform does a great job of storing partial state if something goes wrong, but for extra protection, turn on `versioning` as well by defining a `versioning` block and setting `enabled` to `true`.

    resource "aws_s3_bucket" "tfstate_store" {
      bucket = "superorbital-discover0-tfstate"
      acl    = "private"

      versioning {
        enabled = true
      }
    }

A few more attributes are needed within this same resource. If we ever want to destroy this bucket, it will be inconvenient to have to manually delete all the contents first. By setting `force_destroy=true`, we give ourself an easy way to destroy this bucket in the future.

    resource "aws_s3_bucket" "tfstate_store" {
      # ...
      force_destroy = true
    }

**NOTE** If this bucket is being used for production infrastructure, it may be a good idea to make it difficult to accidentally destroy the entire bucket and all its contents. Never set `force_destroy=true` for production systems or heavily used development or staging systems.

### Step 1.2

Next, create a second S3 bucket for logging. Give it a Terraform identifier such as `logs` and a unique name within AWS such as `superorbital-discover0-tfstate-logs`.

For security, set access control to `log-delivery-write` so only the logging engine can write to the bucket.

    resource "aws_s3_bucket" "logs" {
      bucket = "superorbital-discover0-tfstate-logs"
      acl    = "log-delivery-write"
    }

Configure the existing S3 bucket to perform logging to the new `logs` bucket. Add these lines to the `tfstate_store` resource from above.

    resource "aws_s3_bucket" "tfstate_store" {
      # ...
      logging {
        target_bucket = "${aws_s3_bucket.logs.id}"
        target_prefix = "log/"
      }
    }

The entire file should now look like this:

    provider "aws" {
      version    = "~> 1.30"
    }

    resource "aws_s3_bucket" "tfstate_store" {
      bucket = "superorbital-discover0-tfstate"
      acl    = "private"
      force_destroy = true

      versioning {
        enabled = true
      }

      logging {
        target_bucket = "${aws_s3_bucket.logs.id}"
        target_prefix = "log/"
      }
    }

    resource "aws_s3_bucket" "logs" {
      bucket = "superorbital-discover0-tfstate-logs"
      acl    = "log-delivery-write"
    }

### Step 1.3

Provision the buckets with `terraform init` and `terraform apply`:

    $ terraform init
    $ terraform apply

You should see a success message from the command.  If you want to double-check your work, you can see the bucket location using the `aws` command line tool:

    $ aws s3api get-bucket-location --bucket=superorbital-discover1-tfstate
    {
        "LocationConstraint": "us-west-2"
    }

## Task 2: Bootstrap the configuration to store its own state on S3

Now that we have created a bucket, any new Terraform projects can be configured to store their state in it. But for the purposes of this tutorial, let's store the bucket creation project's own state in S3. We'll also emit an output so another project can read it.

### Step 2.1

Define a `terraform` stanza at the top of the file to use the S3 bucket that was just created. Use `s3` as the `backend`. Define the name of the bucket and the name of the file in which state will be stored (as `key`).

**NOTE** Due to the sequence by which Terraform boots itself, these values must be hard-coded. We can save some trouble by using environment variables for the AWS credentials that have been preconfigured for you.

    # create-s3-bucket/main.tf
    terraform {
      backend "s3" {
        # Be sure to use the same name, here.
        bucket  = "superorbital-discoverN-tfstate"
        key     = "root.tfstate"
        encrypt = true
      }
    }

### Step 2.2

Bootstrap the project's configuration into its own bucket by running `terraform init`, which will copy over existing state file to the S3 bucket. You'll be prompted to make the transfer.

    $ terraform init

    Initializing the backend...
    Do you want to copy existing state to the new backend?
    Pre-existing state was found while migrating the previous "local" backend
    to the newly configured "s3" backend. No existing state was found in the
    newly configured "s3" backend. Do you want to copy this state to the new
    "s3" backend? Enter "yes" to copy and "no" to start with an empty state.

    Enter a value: yes

    Successfully configured the backend "s3"! Terraform will automatically
    use this backend unless the backend configuration changes.

### Step 2.3

In order to give us a value to read in the next step, define one output. Let's reuse the `public_ip` idea from the previous lab. The exact value is hard-coded as part of this lab and doesn't have any other meaning.

    # create-s3-bucket/main.tf
    output "public_ip" {
      value = "8.8.8.8"
    }

Run `terraform apply` and the updated state will be silently read and written to S3 as configured.

    $ terraform apply

Congratulations! You're now storing state remotely.

## Task 3: Create a second Terraform project that reads from the primary project's remote state

As the final task in this lab, let's create a new project in a new directory. It will read the stored state from the previous `create-s3-bucket` project and will print the value of that project's `public_ip` output to its own output.

### Step 3.1

Create a new directory and `main.tf` file for the new project.

    $ cd ..
    $ mkdir use-state
    $ cd use-state
    $ vim main.tf

Since the remote S3 bucket has already been provisioned, we can point this brand new project at the S3 bucket before any other work has been done.

Define a similar `terraform` stanza at the top of the file. Define an `s3` backend and the same `bucket` name as before. However, we want to store this project's state in its own file. So for `key`, use a value that identifies this project, such as `use-state.tfstate`.

    # use-state/main.tf
    terraform {
      backend "s3" {
        bucket  = "superorbital-discover0-tfstate"
        key     = "use-state.tfstate"
        encrypt = true
      }
    }

Now without any other code, we can `init` and `apply` the project and the new (but empty) state will be stored in S3 alongside the `root` project's state.

    $ terraform init
    $ terraform apply

Even if we didn't need to read from another project's state, we would benefit from versioning, logging, and minimal collaboration by storing this project's state in cloud-based storage.

### Step 3.2

We want to build an enterprise scale, robust collaboration system for not only storing state, but sharing output values between projects. For example, one Terraform configuration might create a VPC and emit the VPC ID in an `output`. Other projects could read that ID and create their resources inside the previously created VPC.

We know that we'll be using Amazon Web Services resources, so declare the `aws` provider.

    # use-state/main.tf
    provider "aws" {
      version    = "~> 1.30"
    }

Next, configure a data source that points at the `root` state file. We'll use this to read from that project's `output` values. The `terraform_remote_state` data source implements all the functionality you need. It supports several cloud providers, but we'll be using `s3` as the `backend`.

Credentials are provided with our previously mentioned environment variables. However, the name of the `bucket` and the `key` (filename) of the other project's state file are needed (`root.tfstate`).

    # use-state/main.tf
    data "terraform_remote_state" "root" {
      backend = "s3"

      config {
        bucket = "superorbital-discover0-tfstate"
        key    = "root.tfstate"
      }
    }

Run `init` again to install the necessary supporting files.

    $ terraform init

### Step 3.3

To verify that we've successfully retrieved the `public_ip` value from the `root` project, let's emit its value to our own output.

You'll use the standard Terraform syntax to find the value based on the names of resources specified so far: `terraform_remote_state`, `root`, and the other projects output, `public_ip`.

    # use-state/main.tf
    output "public_ip" {
      value = "${data.terraform_remote_state.root.public_ip}"
    }

Run `apply` to see the output.

    $ terraform apply

    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

    Outputs:

    public_ip = 8.8.8.8

It worked! You won't find the value `8.8.8.8` in the `use-state` project. It was read from the `root` (`create-s3-bucket`) project.

### Step 3.4

Now that you have written and run the code, you can `destroy` the resources that you created (in both projects).

    $ pwd
    ~/store-state/use-state
    $ terraform destroy
    $ cd ../create-s3-bucket
    $ terraform destroy
    ...

    Failed to save state: failed to upload state: NoSuchBucket: The specified bucket does not exist
            status code: 404, request id: F0733311BFCDBA62, host id: bHTB61vPk3ttBR0M8Fgv+EUPx5XFicUtRTVcCAYnYIjwCkwGSACV3w1dFq63xAg8zYNPV1skJCM=

    Error: Failed to persist state to backend.

    The error shown above has prevented Terraform from writing the updated state
    to the configured backend. To allow for recovery, the state has been written
    to the file "errored.tfstate" in the current working directory.

    Running "terraform apply" again at this point will create a forked state,
    making it harder to recover.

    To retry writing this state, use the following command:
        terraform state push errored.tfstate

**QUESTION** Why did you get that error while destroying the second workspace?
