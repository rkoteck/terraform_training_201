# Lab: Run the Sentinel Simulator

This lab demonstrates...

- Task 1: Using the JSON and Sockaddr imports

## Prerequisites

Double check that the required commands and your AWS environment variables have been properly configured for you:

    $ which sentinel
    ~/bin/Linux/sentinel

## Task 1: Using the JSON and Sockaddr imports

This time your policy has a global array called `firewall-rules`.  The array is populated with json blobs, each of which describes a firewall rule.  The blobs have the form:

    {"direction": "egress", "host":"192.168.1.2"}

Edit `addresses.sentinel` to examine the firewall rules, allowing any egress and denying any rule that tries to open ingress unless the external host is in our `192.168.*.*` network.

Once again, you'll know that you got the policy right if `sentinel test` passes.
