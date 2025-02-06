# Terraform with AWS #

## I. Build ##

### 1. Write configuration ###

The set of files used to describe infrastructure in Terraform is known as a Terraform configuration. You will write your first configuration to define a single AWS EC2 instance.

- Each Terraform configuration must be in its own working directory. Create a directory for your configuration.

    `$ mkdir terraform`

- Change into the directory.

    `cd terraform`
- Create a file to define your infrastructure.

    `touch main.tf`

- Open `main.tf` in your text editor, paste in the configuration below, and save the file.

``` Terraform
    terraform {
        required_providers {
            aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
            }
        }
        required_version = ">= 1.2.0"
    }

    provider "aws" {
        region  = "us-west-2"
    }

    resource "aws_instance" "app_server" {
        ami           = "ami-830c94e3"
        instance_type = "t2.micro"

        tags = {
            Name = "ExampleAppServerInstance"
        }
    }
```

## II. Change ##

### 1. Prerequisites ###

- Install the Terraform CLI (1.2.0+), and the AWS CLI (configured with a default profile), as described in the last tutorial.

- Create a directory named learn-terraform-aws-instance and paste the following configuration into a file named main.tf.

``` code
    terraform {
        required_providers {
            aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
            }
        }
        required_version = ">= 1.2.0"
    }

    provider "aws" {
        region  = "us-west-2"
    }

    resource "aws_instance" "app_server" {
        ami           = "ami-830c94e3"
        instance_type = "t2.micro"
        tags = {
            Name = "ExampleAppServerInstance"
        }
    }

```

- Initialize the configuration.
  
    `terraform init`

- Apply the configuration. Respond to the confirmation prompt with a yes.

    `terraform apply`

### 2. Configuration ###

Now update the ami of your instance. Change the aws_instance.app_server resource under the provider block in main.tf by replacing the current AMI ID with a new one.

Tip.
*) Tip
The below snippet is formatted as a diff to give you context about which parts of your configuration you need to change. Replace the content displayed in red with the content displayed in green, leaving out the leading + and - signs.

```code
    resource "aws_instance" "app_server" {
        -  ami           = "ami-830c94e3"
        +  ami           = "ami-08d70e59c07c61a3a"
        instance_type = "t2.micro"
    }
```

### 3. Apply Changes ###

After changing the configuration, run `terraform apply` again to see how Terraform will apply this change to the existing resources.

The prefix -/+ means that Terraform will destroy and recreate the resource, rather than updating it in-place. Terraform can update some attributes in-place (indicated with the ~ prefix), but changing the AMI for an EC2 instance requires recreating it. Terraform handles these details for you, and the execution plan displays what Terraform will do.

Additionally, the execution plan shows that the AMI change is what forces Terraform to replace the instance. Using this information, you can adjust your changes to avoid destructive updates if necessary.

Once again, Terraform prompts for approval of the execution plan before proceeding. Answer yes to execute the planned steps.

## III. Destroy ##

### 1. Destroy ###

The `terraform destroy` command terminates resources managed by your Terraform project. This command is the inverse of terraform apply in that it terminates all the resources specified in your Terraform state. It does not destroy resources running elsewhere that are not managed by the current Terraform project.

Destroy the resources you created.

``` code
$ terraform destroy
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.app_server will be destroyed
  - resource "aws_instance" "app_server" {
      - ami                          = "ami-08d70e59c07c61a3a" -> null
      - arn                          = "arn:aws:ec2:us-west-2:561656980159:instance/i-0fd4a35969bd21710" -> null
    }
##...

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

The - prefix indicates that the instance will be destroyed. As with apply, Terraform shows its execution plan and waits for approval before making any changes.

Answer yes to execute this plan and destroy the infrastructure.

``` code
 Enter a value: yes

aws_instance.app_server: Destroying... [id=i-0fd4a35969bd21710]
aws_instance.app_server: Still destroying... [id=i-0fd4a35969bd21710, 10s elapsed]
aws_instance.app_server: Still destroying... [id=i-0fd4a35969bd21710, 20s elapsed]
aws_instance.app_server: Still destroying... [id=i-0fd4a35969bd21710, 30s elapsed]
aws_instance.app_server: Destruction complete after 31s

Destroy complete! Resources: 1 destroyed.
```

Just like with apply, Terraform determines the order to destroy your resources. In this case, Terraform identified a single instance with no other dependencies, so it destroyed the instance. In more complicated cases with multiple resources, Terraform will destroy them in a suitable order to respect dependencies.

## IV. Variables ##

### 4.1. Prerequisites ###

After following the earlier tutorials, you will have a directory named learn-terraform-aws-instance with the following configuration in a file called `main.tf`.

``` code
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

```

Ensure that your configuration matches this, and that you have run terraform init in the learn-terraform-aws-instance directory.

### 2. Set the instance name with a variable ###

The current configuration includes a number of hard-coded values. Terraform variables allow you to write configuration that is flexible and easier to re-use.

Add a variable to define the instance name.

Create a new file called `variables.tf` with a block defining a new `instance_name` variable.

``` code
variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}
```

In `main.tf`, update the `aws_instance` resource block to use the new variable. The `instance_name` variable block will default to its default value ("ExampleAppServerInstance") unless you declare a different value.

``` code
 resource "aws_instance" "app_server" {
   ami           = "ami-08d70e59c07c61a3a"
   instance_type = "t2.micro"

   tags = {
-    Name = "ExampleAppServerInstance"
+    Name = var.instance_name
   }
 }
```

### 3. Apply your configuration ###

Apply the configuration. Respond to the confirmation prompt with a `yes`.

``` code
$ terraform apply

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.app_server will be created
  + resource "aws_instance" "app_server" {
      + ami                          = "ami-08d70e59c07c61a3a"
      + arn                          = (known after apply)
##...

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server: Creating...
aws_instance.app_server: Still creating... [10s elapsed]
aws_instance.app_server: Still creating... [20s elapsed]
aws_instance.app_server: Still creating... [30s elapsed]
aws_instance.app_server: Still creating... [40s elapsed]
aws_instance.app_server: Creation complete after 50s [id=i-0bf954919ed765de1]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Now apply the configuration again, this time overriding the default instance name by passing in a variable using the `-var` flag. Terraform will update the instance's `Name` tag with the new name. Respond to the confirmation prompt with `yes`.

``` code
$ terraform apply -var "instance_name=YetAnotherName"
aws_instance.app_server: Refreshing state... [id=i-0bf954919ed765de1]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.app_server will be updated in-place
  ~ resource "aws_instance" "app_server" {
        id                           = "i-0bf954919ed765de1"
      ~ tags                         = {
          ~ "Name" = "ExampleAppServerInstance" -> "YetAnotherName"
        }
        # (26 unchanged attributes hidden)




        # (4 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server: Modifying... [id=i-0bf954919ed765de1]
aws_instance.app_server: Modifications complete after 7s [id=i-0bf954919ed765de1]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

## V. Outputs ##

### 1. Initial configuration ###

``` code
# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

# variables.tf

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}
```

Ensure that your configuration matches this, and that you have initialized your configuration in the `terraform` directory.

`terraform init`

Apply the configuration before continuing this tutorial. Respond to the confirmation prompt with a `yes`.

`terraform apply`

### 2. Output EC2 instance configuration ###

Create a file called `outputs.tf` in your `terraform` directory.

Add the configuration below to `outputs.tf` to define outputs for your EC2 instance's ID and IP address.

``` code
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
```

### 3. Inspect output values ###

You must apply this configuration before you can use these output values. Apply your configuration now. Respond to the confirmation prompt with `yes`.

```code
$ terraform apply
aws_instance.app_server: Refreshing state... [id=i-0bf954919ed765de1]

Changes to Outputs:
  + instance_id        = "i-0bf954919ed765de1"
  + instance_public_ip = "54.186.202.254"

You can apply this plan to save these new output values to the Terraform state,
without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-0bf954919ed765de1"
instance_public_ip = "54.186.202.254"
```

Terraform prints output values to the screen when you apply your configuration. Query the outputs with the `terraform output` command.

```code
$ terraform output
instance_id = "i-0bf954919ed765de1"
instance_public_ip = "54.186.202.254"
```

### 4. Destroy infrastructure ###

Destroy your infrastructure. Respond to the confirmation prompt with `yes`.

```code
$ terraform destroy

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.app_server will be destroyed
  - resource "aws_instance" "app_server" {
      - ami                          = "ami-08d70e59c07c61a3a" -> null
      - arn                          = "arn:aws:ec2:us-west-2:561656980159:instance/i-0bf954919ed765de1" -> null
    }
##...

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - instance_id        = "i-0bf954919ed765de1" -> null
  - instance_public_ip = "54.186.202.254" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.app_server: Destroying... [id=i-0bf954919ed765de1]
aws_instance.app_server: Still destroying... [id=i-0bf954919ed765de1, 10s elapsed]
aws_instance.app_server: Still destroying... [id=i-0bf954919ed765de1, 20s elapsed]
aws_instance.app_server: Still destroying... [id=i-0bf954919ed765de1, 30s elapsed]
aws_instance.app_server: Destruction complete after 31s

Destroy complete! Resources: 1 destroyed.
```
