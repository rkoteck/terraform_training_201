# Lab: Run the Sentinel Simulator

This lab demonstrates...

- Task 1: Running a simple sentinel policy via the command line
- Task 2: Getting better output from the sentinel simulator

## Prerequisites

Double check that the required commands and your AWS environment variables have been properly configured for you:

    $ which sentinel
    ~/bin/Linux/sentinel

## Task 1: Running a simple sentinel policy via the command line

The sentinel simulator is the command line tool that allows you to run policies locally and develop policies in a test-driven workflow.  We're going to implement a trivial policy using the simulator.

Create a file named `trivial.sentinel` with the following contents:

    main = rule { true }

Now run that policy with the `sentinel` command.  Remember that you can get usage instructions with the `-h` flag.

You'll know you got it right when you see `Pass` as the output.

## Task 2: Getting better output from the sentinel simulator

The simulator has a `-trace` flag, which is useful for understanding how your policy is behaving.  Most helpful is that it returns intermediate values from your various rules.

Run the policy again, using `-trace`.  You should see something like:

    Pass

    Execution trace. The information below will show the values of all
    the rules evaluated and their intermediate boolean expressions. Note
    that some boolean expressions may be missing if short-circuit logic
    was taken.

    TRUE - trivial.sentinel:1:1 - Rule "main"

The first line tells us that our policy passed, and the line at the end tells us that our `main` rule returned `true`.  Not incredibly useful.  Let's make a new policy that's a bit more interesting, just to understand how `-trace` can help us out.

Create a policy named `convoluted.sentinel`, with the following content:

    current_catch = 23
    catch_22 = rule { current_catch == 22 }
    reality_check = rule { 1 + 1 == 2 }
    main = rule { reality_check and not catch_22 }

Now run it with `-trace`.  Examine the output with your partner.  What's it telling us?

Let's discuss as a class.
