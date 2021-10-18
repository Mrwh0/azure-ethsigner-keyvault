# single_key_runtest_sample.py

## login az cli, create new service principal and create env variables for the vault sdk
**if you already have a service principal avoid this**

```bash
az login -t "your_tenat_here"
az ad sp create-for-rbac --name http://test-ksm --skip-assignment

{
  "appId": "new_app_id_here",
  "displayName": "http://test-ksm",
  "name": "new_app_id_here",
  "password": "ramdon_pasword_here",
  "tenant": "your_tenant_here"
}

az keyvault set-policy --name "eth-signer-app-name-here" --spn "new_app_id_here" --key-permissions get list create

export AZURE_CLIENT_ID="new_app_id_here"
export AZURE_CLIENT_SECRET="ramdon_pasword_here"
export AZURE_TENANT_ID="your_tenant_here"
```

## install deps and test-run

```bash
sudo python3.6 -m pip install web3 eth_keys azure-keyvault-keys azure-identity
sudo apt install python3-gi python3-gi-cairo gir1.2-secret-1
python3.6 single_key_runtest_sample.py
```
