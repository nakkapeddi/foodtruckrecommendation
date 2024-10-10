# FoodTruckRecommender

## Introduction

This repository contains a Phoenix application that implements a food truck recommender. 

## Local Development environment

To activate the development environment, you will need to install [Nix](https://nixos.org/download/) on your local machine. 

After that, activate the nix environment by running:

`nix develop`

Inside of Nix, Elixir was complaining about my locale (set to default as C).

To fix this, run (prior to invoking `nix develop`):

```
nix-env -iA nixpkgs.glibcLocales
export LOCALE_ARCHIVE="$(nix-env --installed --no-name --out-path --query glibc-locales)/lib/locale/locale-archive"
```

## Building & Running inside of local env

Inside of the nix env, we just need to run the `mix` commands for phoenix:

```
mix deps.get
mix compile
mix phx.server
```

## Deploying

To deploy, I decided to go with `terraform` to provision an EC2 instance and store app artifacts in an S3 bucket.

First run:
```
cd terraform
terraform init -var-file="prod.tfvars"
```

Then plan (for reproducibility purposes, the plan is saved to an output file):
```
terraform plan -var-file="prod.tfvars" -out <plan_name>.tfplan
```

Finally perform the actual deployment (vars are stored in the tfplan, from when you invoked `terraform plan`)

```
terraform apply "<plan_name>.tfplan"
```

To teardown

```
terraform apply -destroy -var-file=prod.tfvars
```

Example prod.tfvars
```
s3_bucket_name    = "elixir-app-artifacts-20241009"
aws_region        = "us-east-1"
ec2_instance_type = "t3.micro"
ec2_ami           = "ami-0c94855ba95c71c99"
```

## Extensions

* I skipped enabling Ecto, but a feature enhancement could be to enable Ecto and setup a Postgres DB, to store previous user recommendations.
* Could use an LLM for recommendations based on preferences and previous recommendations. 
* Test cases for backend 