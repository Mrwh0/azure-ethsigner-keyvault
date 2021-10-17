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
az --version 
# note azure-cli must be 2.29.0, the 2.28.0 had an ugly coinater lib bug 

```

# login azure with cli & deploy

```

# log with specific tenant
az login -t 6a3ee749-b708-41fa-8aba-46beca6fa849
cd terraform
terraform init
terraform validate
terraform plan -out plan.txt
terraform apply plan.txt
# note after deploy take copy "random_string.this: Refreshing state... [id=xxxxxxxxxxxxx]" somewhere
```

# debug

## Chek the eth-signer container info
```
cointigo@nixbox2:~/nft$ az container list

```

## Check eth-siger conatiner logs

```
cointigo@nixbox2:~/nft$ az container logs --name aci-ethsigner --resource-group rg-ethsigner-eastus

Setting logging level to INFO
2021-10-17 01:11:40.763+00:00 | main | INFO  | SignerSubCommand | Version = ethsigner/v21.3.0/linux-x86_64/-na-openjdk64bitservervm-java-11
2021-10-17 01:11:44.534+00:00 | main | INFO  | KeyAsyncClient | Retrieving key - key-ethsigner
2021-10-17 01:11:49.695+00:00 | reactor-http-epoll-1 | INFO  | KeyAsyncClient | Retrieved key - key-ethsigner
2021-10-17 01:11:49.776+00:00 | main | INFO  | CryptographyServiceClient | Retrieving key - key-ethsigner
2021-10-17 01:11:49.962+00:00 | reactor-http-epoll-1 | INFO  | CryptographyServiceClient | Retrieved key - key-ethsigner
2021-10-17 01:11:52.053+00:00 | main | INFO  | Runner | Server is up, and listening on 8545
```



## Test eth-signer container working properly against the downstream (the RPC)

```
cointigo@nixbox2:~/nft$ az container exec --name aci-ethsigner --resource-group rg-ethsigner-eastus --exec-command "/bin/bash"

root@SandboxHost-637700298678944975:/opt/ethsigner# apt-get update
root@SandboxHost-637700298678944975:/opt/ethsigner# apt-get install curl

# check if eth-signer is up
root@SandboxHost-637700298678944975:/opt/ethsigner# curl -X GET http://127.0.0.1:8545/upcheck
I'm up!

# check downstream rpc client version 
root@SandboxHost-637700298678944975:/opt/ethsigner# curl --location --request POST 'http://127.0.0.1:8545' --header 'Content-Type: application/json' --data-raw '{  "jsonrpc":"2.0", "method":"web3_clientVersion", "params":[], "id":1 }'
{"jsonrpc":"2.0","result":"OpenEthereum//v3.3.0-rc.6-stable-5d9ff63-20210804/x86_64-linux-gnu/rustc1.52.1","id":1}

# check downstream last block
root@SandboxHost-637700298678944975:/opt/ethsigner# curl --location --request POST 'http://127.0.0.1:8545' --header 'Content-Type: application/json' --data-raw '{  "jsonrpc":"2.0", "method":"eth_blockNumber", "params":[], "id":1 }'
{"jsonrpc":"2.0","result":"0xd9345","id":1}

```
