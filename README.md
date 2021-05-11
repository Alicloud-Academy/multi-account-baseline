# A Rough "Alibaba Cloud Multi-Account Baseline" Implementation

- Terraform Version: v0.15.0
- Alibaba Cloud Provider Version: v1.121.2
- Status: Script working as of 2021-05-11 (YYYY-MM-DD)

## What

This script demonstrates multi-account best practices on Alibaba Cloud.

## How

Right now, some of the setup work must be done manually. Here's the basic process:

1. Enable Resource Directory (资源目录) under your Alibaba Cloud account. Your account **must be a business (enterprise) account** in order to do this.
2. Create several new accounts inside Resource Directory. I recommend the following naming convention:
    1. SharedServices (shared services will live here)
    2. App0 (your first application / team account)
    3. App1 (your second application / team account)
3. Create a new RAM user inside your Alibaba Cloud (master) account, with  the `AdministratorAccess` policy attached. 
4. Make sure you can log in using this RAM user, and test logging in to your new Resource Directory accounts using this RAM user. 
5. Note down the Alibaba Cloud Account IDs of your `SharedServices`, `App0`, and `App1` accounts.

Fill in the blanks in `terraform.tfvars`, make a few configuration changes in `main.tf` under the root directory of this project, and off you go! For more details on design, best practices, and step-by-step usage, see the included word document.

## Limitations of The Code

This code makes some assumptions:
- Each application account has just 3 VPCs (Dev, UAT, and Prod)
- Dev VPCs have 3 VSwitches (1 Availability Zone x 3 subnets)
- UAT VPCs have 6 VSwitches (2 Availability Zones x 3 subnets)
- Prod VPC groups have 9 VSwitches (3 Availability Zones x 3 subnets)
- All applications are subnetted inside the 172.16.0.0/12 address space
- Because of the way 172.16.0.0/12 is subnetted, there can be **no more than 5** application accounts (for the demo we recommend limiting yourself to 2). 

Other limitations include:
- You have to update/rerun the code as new Application accounts are added.
- Each application account needs to have a distinct "app_id" (a number from 0 to 4) set before the Terraform code is run. **This is important because it's used to decide how VPC CIDR blocks should be set up**. 

## Running the Code

### Shared Services Account

You need to first set up the Resource Directory (资源目录) and its subdirectories, and create RAM accounts and access keys as described above.

Once this has been done, you can add the required information to `terraform.tfvars`. Then, from the root directory (where this README file is located), run:

```
terraform init
```

Followed by:

```
terraform plan -out baseline
```

And finally: 

```
terraform apply baseline
```

Once you've reviewed the changes this will make, approve them by typing in "yes" at the prompt, then hit enter.

Remember, you'll have to **re-run terraform** (and make some changes to terraform.tvfars, outputs.tf, and main.tf) **each time you add a new application account**.

## The ECS Testbed

There's a module called "ecs_testbed" which you can use to create ECS instances. This lets you test out centralized logging and also gives you a way to test network connectivity between different subnets using `ping`.

## Un-running the Code (Deleting Things)

This should be as simple as `terraform destroy`, but this is a pretty complicated script and it sets up a lot of resources under multiple accounts. Depending on how things go, you may find yourself doing some cleanup by hand. If you find an issue, let us know.

You may have to run `terraform destroy` more than once, or even manually delete resources via the console.

## Todo

Stuff we'd like to add:
- More automation
- Secrets management
- Service catalog ("approved" disk images)
- CloudConfig support
- Multi-account WAF and Security Center support

Check back from time to time. We'll update the code and documentation as we make changes.
