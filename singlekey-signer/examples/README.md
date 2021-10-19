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

#edit vault_url & eth_signer_url in single_key_runtest_sample.py
python3.6 single_key_runtest_sample.py


 HSM test-run
 new_ec_key_pair      : single-test
 list_keys_ids        : ['key-ethsigner', 'single-test', 'user1', 'user2']
 get_specific_json_key: <azure.keyvault.keys._models.JsonWebKey object at 0x7fb110bbf710>
 eth_address_from_hsm : 0xDc257F5545e5eA91Cd539F702C0060F69439ab70

 ETH-SIGNER test-run
 eth_signer_accounts  : ['0xF7Eee58CaE7706284586832420C5B4cfaAC298e4']
 test_regular_tx      : 0x8906f11b657eb983a6113a4b4028d0eb6036df5873048d0d5bd1363aba45ad98
 test_erc_transfer    : 0x960e197ef7da28081c4b8ebde38049a88bba07a5b59e1c9f16261ccaa40cd98c
 

```
