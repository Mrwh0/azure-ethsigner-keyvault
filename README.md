# what is this?

**terraform script to deploy:**

1. Azure Active Directory application, service principal and service principal password 
2. Azure Key Vault and HSM "SECP256K1"
3. eth-signer container 

# install deps

```bash
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg unzip wget

wget https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip
unzip terraform_1.0.9_linux_amd64.zip
mv terraform /usr/local/bin/

curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
sudo apt-get install azure-cli
```

# deploy

```
az login
cd terraform
terraform init
terraform validate
terraform plan -out plan.txt
terraform apply plan.txt
```

# error 

```
~/terraform terraform apply plan.txt 
azuread_application.this: Creating...
azurerm_resource_group.this: Creating...
azurerm_resource_group.this: Creation complete after 1s [id=/subscriptions/xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx/resourceGroups/rg-ethsigner-eastus]
╷
│ Error: Could not create application
│ 
│   with azuread_application.this,
│   on main.tf line 34, in resource "azuread_application" "this":
│   34: resource "azuread_application" "this" {
│ 
│ graphrbac.ApplicationsClient#Create: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403
│ Code="Unknown" Message="Unknown service error"
│ Details=[{"odata.error":{"code":"Authorization_RequestDenied","date":"2021-10-15T02:07:14","message":{"lang":"en","value":"Insufficient privileges to
│ complete the operation."},"requestId":"4f2e5be1-1be6-4793-bd4a-61823c98a62f"}}]
╵
```
