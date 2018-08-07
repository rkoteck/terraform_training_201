# Lab 13: Module Configuration Tool

This lab demonstrates how to import an existing Terraform module into the private module registry, and then configure variables so the module can be used from a new Terraform configuration project.

- Task 1: Add a module to the private registry
- Task 2: Configure the module with the web UI

## Prerequisites

For this lab, we're going to use the same Github repo you created for the `public-registry` lab (you likely named it something like `terraform-demo-animal`).

## Task 1: Add a module to the private registry

The private module registry works like the public module registry, with the addition of the module configuration tool. But in order to use the configuration tool, you'll need to have at least one private module in your organization's registry.

### Step 13.1.1: Add a module

Go to https://app.terraform.io/ and click the "Modules" button in the header. On the "Modules" page you'll see the "+ Add Module" button on the right. Click it.

Select the "GitHub" VCS connection that you've already set up. Find your Github repo in the search box, and click "Publish Module."

You'll know that it worked when you see a page that lists the module with a description and a code snippet for using it.

## Task 2: Configure the module with the web UI

The Terraform Enterprise module configuration designer supports a producer/consumer pattern where some teams create modules and other teams use them to create infrastructure. You'll pretend to be a consumer and use the configuration designer to generate code that can be copy-and-pasted into a new Terraform project.

### Step 13.2.1: Launch the configuration designer

Start by either clicking the "Open in Configuration Designer" button under the right hand code snippet, or go back to the organization dashboard and click the "+ Design Configuration" button.

You'll now see a screen with a list of modules. Click the "Add Module" button on the `animal` module that you imported.

### Step 13.2.2: Configure variables

Click the green "Next" button to proceed to the configuration screen. You'll see a list of variables, a description of each, and an input field where you can type a value for the variable.

Type any name into the name field, such as "web", and click the large green "Next" button on the top right.

You'll be taken to a screen where you can preview the generated code, or download it as a file (it will be named `main.tf`).

In a production scenario, you would save this file to a new or existing Terraform project, add it to a repository in your source code control system, and connect the repository to Terraform Enterprise for provisioning.
