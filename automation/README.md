# Working in docker

The Dockerfile in this repository creates an image with terraform and the azure cli installed. 

You can use this image to run terraform commands without having to install anything on your local machine.

**Don't forget to mount the terraform folder into the running container**

1. Use `az login --use-device-code` to login to your azure account. (there won't be a browser in the container)
2. Select the right subscription after login or use `az account set --subscription "<your-subscription-id>"` to set the subscription you want to use.
3. Run terraform commands

# Setup and Preparation

1. The terraform needs a new service principal to be able to create resources in your Azure subscription. You can create a new service principal using the Azure CLI with the following command:

```bash
az ad sp create-for-rbac --name "<your-service-principal-name>" --role="Contributor" --scopes="/subscriptions/<your-subscription-id>"
```

Replace `<your-service-principal-name>` with a name for your service principal and `<your-subscription-id>` with your Azure subscription ID. This command will output the `appId`, `password`, `tenant`, and other details needed for authentication.

2. This service principal needs an extra Role to be able to create Role Assignments. It can be done on the portal
   1. Select the subscription
   2. Go to Access Control (IAM)
   3. Click on Add -> Add custom role
   4. Give it name
   5. Select Permissions: Microsoft.Authorization/*/Write
   6. Create
   7. Go back and click on Add -> Add role assignment
   8. Select the custom role you just created
   9. Assign to the service principal you created in step 1
   10. Save

3. Terraform should be able to run properly now and create the resources and role assignments

# Initialize Terraform

Before running any Terraform commands, you need to initialize your Terraform configuration. This step downloads the necessary provider plugins and sets up the backend for storing the state file.

```bash
terraform init
```

