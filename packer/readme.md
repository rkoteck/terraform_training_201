# Lab: Packer

This lab demonstrates...

- Task 1: Build an image with Packer
- Task 2: Simulate an error to prove that incorrect images will fail
- Task 3: Edit `demo-terraform-101` to use the Packer-generated AMI

## Prerequisites

Double check that the `packer` binary and your AWS environment variables have been properly configured for you:

    $ which packer
    /home/discover0/bin/Linux/packer

    $ env | grep AWS
    AWS_ACCESS_KEY_ID=AKI...
    AWS_SECRET_ACCESS_KEY=PSD...
    AWS_DEFAULT_REGION=us-west-2

## Task 1: Build an image with Packer

You'll create an AWS AMI that enhances an existing Ubuntu image with a Go web application that displays a list of live visitors to the page. It will start on boot and be served on port 80.

### Step 1.1: Write a Packer JSON file

Copy the following into a `json` file. The exact name is irrelevant. Try something like `web-visitors.json`.

**Hint:** If you're using vi, then you may want to `:set paste` before pasting the contents into the file.

    {
      "variables": {
        "aws_source_ami": "ami-bd8f33c5"
      },
      "builders": [
        {
          "type": "amazon-ebs",
          "region": "us-west-2",
          "source_ami": "{{user `aws_source_ami`}}",
          "instance_type": "t2.small",
          "ssh_username": "ubuntu",
          "ssh_pty": "true",
          "ami_name": "web-visitors-{{timestamp}}",
          "tags": {
            "Created-by": "Packer",
            "OS_Version": "Ubuntu",
            "Release": "Latest"
          }
        }
      ],
      "provisioners": [
        {
          "type": "shell",
          "inline": [
            "mkdir ~/src",
            "cd ~/src",
            "git clone https://github.com/hashicorp/demo-terraform-101.git",
            "cp -R ~/src/demo-terraform-101/assets /tmp",
            "sudo sh /tmp/assets/setup-web.sh"
          ]
        }
      ]
    }

### Step 1.2: Validate the file

Verify that the file is correct by running the `validate` command on it.

    $ packer validate web-visitors.json

You should see that it was successful.

    Template validated successfully.

### Step 1.3: Build the image with Packer

Build the image with the `build` command. This may take a few minutes (possibly even 10 minutes).

    $ packer build web-visitors.json

When it builds successfully, you will see the AMI ID of the new image.

## Task 2: Simulate an error to prove that incorrect images will fail

In this step, you'll intentionally cause an error in the build process so you can see how failures affect the build process.

### Step 2.1: Add `false` to simulate an error

Make a copy of the existing Packer configuration file.

    $ cp web-visitors.json web-visitors-fail.json

At the end of the `provisioners` section in the new document, replace all shell commands with the single value `false`. This will simulate an error and will cause the build to fail.

    {
      "provisioners": [
        {
          "type": "shell",
          "inline": [
            "false"
          ]
        }
      ]
    }

### Step 2.2: Build with error

Run `build` as before. You should see an error.

    $ packer build web-visitors-fail.json

    Build 'amazon-ebs' errored: Script exited with non-zero exit status: 1

This demonstrates that Packer will enforce an extra level of validation and will not proceed if the image did not build cleanly.

## Task 3: Edit `demo-terraform-101` to use the Packer-generated AMI

The existing `demo-terraform-101` that you forked a few chapters ago can be rewritten to use the Packer-generated AMI instead of the `provisioner` code it was originally written with.

### Step 3.1: Edit the `ami` variable in TFE

When a run is triggered from your VCS, Terraform Enterprise will use a snapshot of the variables as defined at the time that the run is triggered.

So we must first edit the `ami` variable before we change the code at GitHub.

Go to the "Variables" tab for your workspace. Click the "Edit" toggle. Find the `ami` variable and enter the ID of the AMI you created with Packer.

Click the "Save" button.

### Step 3.2: Update the code to use the AMI

The existing code already accepts an `ami` variable and feeds that through to the code in `server/main.tf`. Since the Packer-generated AMI is already configured with the Go web application, we can delete all the `provisioner` code in Terraform that accomplishes the same task.

**Note**: You can either complete this in the shell, or by using Github's inline editor.

Go to GitHub and find your fork of `demo-terraform-101`. Find the `server/main.tf` file. Edit the file to remove the following code:

    # Delete the following 15 lines from `aws_instance`
    connection {
      user        = "ubuntu"
      private_key = "${var.private_key}"
    }

    provisioner "file" {
      source      = "assets"
      destination = "/tmp/"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo sh /tmp/assets/setup-web.sh",
      ]
    }

Create a pull request and merge the pull request as you did a few chapters ago.

This will trigger a `plan` in Terraform Enterprise.

### Step 3.3: Run `apply`

Go to Terraform Enterprise and find the most recent run. Scroll to the bottom and approve the `plan`.

This will recreate the instance, but with the new AMI.

Visit the emitted IP address in the browser. The web application should work as before, but is now being provisioned directly from code baked into the AMI.

**NOTE:** Provisioning directly from an AMI usually completes more quickly than similar code provisioned with `provisioner`. Using an AMI eliminates the need to establish an SSH connection to the instance. Subsequent `provisioner` shell commands are no longer needed if the applications have been preconfigured inside the AMI.
