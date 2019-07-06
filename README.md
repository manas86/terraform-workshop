# Terraform Workshop

This is your starting point for the Terraform workshop! This project will set you up with the following:

- A basic environment in your AWS account
- A main node which deploys a personalized dashboard, which you'll get instructions from

This repository also supplies the Terraform executable (found in `terraform/terraform`) for a flying start.

## Getting started
We will be using the `workshop` directory as the working directory during the workshop.

1. Create a file called `terraform.tfvars`
2. Fill it with the following content:
    ```
    username = "YOUR_USERNAME"
    aws_key = "YOUR_AWS_KEY"
    aws_secret = "YOUR_AWS_SECRET"
    ```
3. Replace the `YOUR_USERNAME`, `YOUR_AWS_KEY` and `YOUR_AWS_SECRET` with your actual values. If you do not have a secret access key it can be obtained by creating a new access key.
4. Run `./terraform apply` to spin up your base environment. Type `yes` when required!
5. Wait. When done, the output of Terraform will give you an url. Go to this url, this will be your dashboard for the rest of the workshop!

Note: The Dashboard can take a bit of time to boot up. Give it a minute or so :)

Have fun!
