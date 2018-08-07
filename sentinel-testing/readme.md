# Lab: Sentinel Testing

This lab demonstrates...

- Task 1: Writing a happy-path test.
- Task 2: Writing a failing test.
- Task 2: Writing another failing test.

## Prerequisites

Double check that the required commands have been properly configured for you:

    $ which sentinel
    ~/bin/Linux/sentinel

## Task 1: Writing a happy-path test.

We're going to start from scratch, and write a test named `test/deploy/happy.json` that shows:

* `main` returning `true` (which is why we call this a "happy path" test)
* a rule named `is_weekend` returning false
* a rule named `after_hours` returning false

The test harness should also provide a global named `deploy_freeze` that's set to false, and should mock out the `time` import to return 1 for "day" and 3 for "hour".

If you need help with the JSON schema, take a look at the tests in our previous labs.

Run `sentinel test deploy.sentinel` and watch it fail.

Now, modify the sentinel policy to make the test pass.

## Task 2: Writing a failing test.

You did a great job on the happy path above, but we also want to make sure our policy blocks deploys after working hours.  Copy our happy test case to `test/deploy/after_hours.json` and make these changes:

1. `time.hour` should be set to 10
1. the `after_hours` rule should return true
1. the `main` rule should return false

Now run the tests, watch it fail, and modify `deploy.sentinel` until it passes.  (Note: the test may pass right off the bat, depending on how you implemented Task 1 above.  If so, congratulations!)

## Task 2: Writing another failing test.

Finally, we also want to make sure our policy blocks deploys if we've set a `deploy_freeze` variable.  Copy our `happy` test case to `test/deploy/deploy_freeze.json` and make these changes:

1. the `deploy_freeze` global should return true
1. the `main` rule should return false

And ensure `sentinel test` still passes.

Again, the test may pass right off the bat, depending on how you implemented the previous tasks above.
