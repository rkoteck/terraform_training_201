# Lab: The Registry

This lab demonstrates...

- Task 1:  Create a Github repository with your module code.
- Task 2:  Create an account with the Terraform Registry.
- Task 3:  Use your module.
- Task 4:  Add a required variable.

## Task 1:  Create a Github repository with your module code.

Open a browser and log-in to https://github.com.  If you don't have a Github account, then either create one now, or work with your pair's account.

Create a new repository:

* Make it **public**
* Add a Terraform `.gitignore` file.
* Name it something like `terraform-PROVIDER-MODULE` (for example: `terraform-demo-animal`).

Clone the repository locally using the `https` url and add the following files:

*  `README.md`

        # Demo Animal module

        Just playing around.

*  `main.tf`

        resource "random_pet" "animal" {}

*  `outputs.tf`

        output "name" {
          value       = "${random_pet.animal.id}"
          description = "Contains the name of a random animal."
        }

Configure git with your Github name and email address.

    $ git config --global user.name "John Doe"
    $ git config --global user.email johndoe@example.com

Now commit those files, tag the commit, and push to Github:

    $ git add -A

    $ git commit -m "Implement module"

    $ git tag "v0.0.1"

    $ git push
    ..and...
    $ git push --tags

If you did it right, you should see your tag under the "Releases" section when you view your repo on https://github.com.

## Task 2: Sign up on the Registry and publish your module

Browse to https://registry.terraform.io/ and click Sign Up.

Sign up using your Github account.

Click "Publish" in the right hand corner.

Find your repo in the dropdown and publish it. _Note: If you don't see it, you may have named the repo incorrectly_

Congratulations!  You've just published your first Terraform module to the world!

Spend some time exploring what the Registry provides.  Note the documentation around inputs, outputs and resources.  It also provides provision instructions that you can copy and paste.

## Task 3: Use your module

Copy and paste the "Provision Instructions" from the Registry into a new `main.tf` file in your home directory.

Add an output that returns `"${module.animal.name}"`

`init` and then `apply` your workspace, and you should see an output that's something like "emerging-opossum"


## Task 4: Add a required variable.

Add a required variable to your module.  Create a `variables.tf` file with the following stanza:

     variable "prefix" {
        description = "What to put in front of the name"
     }

And now use it in your `outputs.tf`:

    "${var.prefix}-${random_pet.animal.id}"

Now add the files, commit the changes, tag the commit, and push the commits and the tags to Github.

Go back to the registry.  Do you see your new version?  What do you see under **Input**?  How has the Provision Instructions changed?

_Note: if you don't see your new version, you may have to click "Resync Module" in the "Manage Module" dropdown._
