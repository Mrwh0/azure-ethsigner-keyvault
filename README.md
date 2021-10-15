# what is this?

1. [active_directory.tf](active_directory.tf) Azure Active Directory application, service principal and service principal password 
2. [key_vault.tf](key_vault.tf) Azure Key Vault and HSM "SECP256K1"
3. [ethsigner.tf](ethsignet.tf) eth-signer container 

# runtest

```bash
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg unzip wget

wget https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_linux_amd64.zip
unzip terraform_1.0.7_linux_amd64.zip
mv terraform /usr/local/bin/

curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
sudo apt-get install azure-cli

cd terraform
terraform init
terraform validate
terraform plan -out plan.txt
terraform apply plan.txt
```
