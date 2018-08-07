# Lab: Run the Sentinel Simulator

This lab demonstrates...

- Task 1: Introduction to sentinel testing
- Task 2: Using all/any/for in you rules

## Prerequisites

Double check that the required commands and your AWS environment variables have been properly configured for you:

    $ which sentinel
    ~/bin/Linux/sentinel

## Task 1: Introduction to sentinel testing

We've provided a stub `pets.sentinel` file and some tests.  Don't worry about how the tests work - we're going to get into that later.  To see the tests in action, run `sentinel test`:

    $ sentinel test
    FAIL - pets.sentinel
      PASS - test/pets/good.json  FAIL - test/pets/bad.json
        expected "pets" to be false, got: true

        trace:
          TRUE - pets.sentinel:1:1 - Rule "pets"

Now, run the same command with the `-verbose` flag, and examine the difference in the output.

## Task 2: Using all/any/for in you rules

We're exposing a global value of `families` to the `pets.sentinel` policy, which is an array of maps.  Each map has an entry named "children" (which is either true or false), and an entry named "dogs" (which is either "mean" or "nice").

Edit the `pets.sentinel` file so that it examines the `families` array and forbids families to have children with mean dogs.  Extra credit if you can break out a sub-rule, and if you can manage to use a function.

Remember, documentation is always at your fingertips:

    https://docs.hashicorp.com/sentinel/writing/testing

You'll know you've gotten it right when `sentinel test` passes.
