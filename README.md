# tf-aws-basic
AWS + Terraform

Sample terraform configuration files to provision and deploy Linux VMs in AWS.  

Instructions:
* Download latest version of Terraform for Windows, [here.] (https://www.terraform.io/downloads.html) to a local folder, eg. c:\Terraform
* Set path system environmental variable, in PowerShell type $env:Path += ";c:\Terraform"
* Launch PowerShell (cmd or git bash) and type terraform to confirm installation.
* Code using any text editor, Visual Studio Code strongly recommended ( there is a Terraform extension for VSC).
* Create a terraform.tfvars with the credentials (do not version control this file).  Use your IAM user's AWS access id and secret keys.

                AWS_ACCESS_KEY_ID = "..."  
                AWS_SECRET_ACCESS_KEY = "..."  
                AWS_DEFAULT_REGION = "..."  
                aws_key_name = "..."  

* Create key pair for your instance's credentials from EC2 dashboard/Network & Security/Key Pairs or use [Puttygen](https://the.earth.li/~sgtatham/putty/latest/x86/puttygen.exe) to generate private and public keys and Terraform's [AWS_KEY_PAIR](https://www.terraform.io/docs/providers/aws/r/key_pair.html) resource type.

This will create a VPC with a public and private subnets, a web server, a db server and a bastion host. It will also create an Internet facing load balancer for the web servers and a NAT Gateway for the private subnet.

