# Lab: Sentinel Testing

This lab demonstrates...

- Task 1: Writing a policy that restricts by region.
- Task 2: Uploading that policy to Terraform Enterprise.
- Task 3: Attempting to subvert the policy.

## Prerequisites

Double check that the required commands have been properly configured for you:

    $ which sentinel
    ~/bin/Linux/sentinel

## Task 1: Writing a policy that restricts by region.

Open `region.sentinel` and take a look at what we've provided.  We've cribbed some code from the Hashicorp documentation that will return all resources recursively, including those produced by modules:

    instances = []
    for tfplan.module_paths as path {
      foo = values(tfplan.module(path).resources.aws_instance) else []
      print(foo)
      instances += foo
    }
    return instances

In addition, we've wrapped it in a function and added a stanza to help us mock this value:

    get_aws_instances = func() {
      if tfplan.resources["mocked"] else false {
        return tfplan.resources["mocked_instances"]
      }
      ...
    }

Finally, we've added a `main` rule that prints out the returned data structure.

Run `sentinel test -verbose` and study the output to understand what `get_all_instances()` returns.  Now, modify the policy to restrict all instances to the `us-west-2` region.  You'll know you've finished when the tests pass.

## Task 2: Uploading that policy to Terraform Enterprise.

Browse to https://app.terraform.io, and add this as a sentinel policy for you organization.  Name it "RestrictRegion" and make it a hard mandatory policy.

## Task 3: Attempting to subvert the policy.

Modify your workspace variables, changing the zone from `us-west-2` to `us-east-1` and click "Save & Plan".  Verify that your plan was blocked.
