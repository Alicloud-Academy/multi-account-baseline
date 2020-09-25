# A Rough "Alibaba Cloud Multi-Account Baseline" Implementation

- Terraform Version: v0.13.2
- Alibaba Cloud Provider Version: v1.98.0
- Status: Script working as of 2020-09-24 (YYYY-MM-DD)

## What

This script demonstrates multi-account best practices on Alibaba Cloud.

## How

Right now, you need to manually configure a 资源目录 (Resource Directory), then set up Shared and App accounts. The process is:

1. Sign up for a "root" account, and create a 资源目录 from the Resource Manager (资源管理) console
2. Configure a Shared Services 资源账号 inside the 资源目录
3. Configure up to 5 application accounts, I recommend naming them "AppA" to "AppE" or "App0" to "App4"
4. Create a RAM account under your root account with the `AdministratorAccess` policy attached
5. Log into this RAM account, then navigate to the Resource Manager (资源管理) console
6. Mouseover any of the 资源账号 accounts to switch role
7. Under each 资源账号 account, create a new RAM account called "terraform" with the AdministratorAccess policy attached
8. Download the RAM account AK Key and Secret Key for each new RAM account (when you download the CSV files, give them obvious names like `shared_services.csv' or 'app_0'.csv so you can keep track of them!)

You can then enter this information into terraform.tfvars, make a few configuration changes in main.tf under the root directory of this project, and off you go! For more details on design, best practices, and step-by-step usage, see the included word document.

## Limitations of The Code

This code makes some assumptions:
- Each application has just 3 VPC groups (dev, uat, and prod)
- Dev VPC groups have 3 vSwitches (1 AZ x 3 subnets)
- UAT VPC groups have 6 vSwitches (2 AZ x 3 subnets)
- Prod VPC groups have 9 vSwitches (3 AZ x 3 subnets)
- All applications are subnetted inside the 172.16.0.0/12 address space
- There are no more than 5 distinct application accounts, all bound to a single Shared Services account (a limitation of using 172.16.0.0/12)

Other limitations include:
- It's necessary to modify the shared services account's main.tf file to add CEN attachments each time a new application account is configured
- Each new application account needs information about the shared service account's UID and CEN ID in order to be created successfully (you can pass this in as you create new modules in main.tf)
- Each application has a distinct "app_id" variable (a number from 0 to 4) set in its local terraform.tfvars

## Running the Code

### Shared Services Account

You need to first set up the Resource Directory (资源目录) and its subdirectories, and create RAM accounts and access keys as described above.

Once this has been done, you can add your Shared Account AK keys to `terraform.tfvars`. Then, from the root directory (where this README file is located), run:

```
terraform init
```

Followed by:

```
terraform plan
```

And finally: 

```
terraform apply
```

Once you've reviewed the changes this will make, approve them by typing in "yes" at the prompt, then hit enter.

Remember, you'll have to **re-run terraform** (and make some changes to terraform.tvfars, outputs.tf, and main.tf) **each time you add a new application account**.

## The ECS Testbed

There's a module called "ecs_testbed" which you can use to create ECS instances. This lets you test out centralized logging and also run `ping` checks to ensure networking between VPCs (CEN peering) is working.

## Un-running the Code (Deleting Things)

This should be as simple as `terraform destroy`, but **deletion hasn't been tested yet!** proceed with caution. You may have to run `terraform destroy` more than once, or even manually delete resources via the console. So take care! 

## Todo

Features to add:
- Fully automate adding new application accounts
- Add additional features, such as "secrets management" (Table Store?) and "Service Catalog" (shared images via packer?)

