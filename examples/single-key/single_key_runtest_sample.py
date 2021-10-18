from azure.identity import DefaultAzureCredential
from azure.keyvault.keys import KeyClient
from eth_keys import KeyAPI
from web3 import Web3, HTTPProvider
import json

azure_vault_url = 'https://xxxxxxxxxxxxx.vault.azure.net/' # vault url here
eth_signer_url  = 'http://xxxxxxxxxxx:8545'                # eth-signer url here

credential = DefaultAzureCredential()
key_client = KeyClient(vault_url=azure_vault_url, credential=credential)
w3         = Web3(HTTPProvider(eth_signer_url))


print("HSM test-run")
def new_ec_key_pair(key_id):
    ec = key_client.create_ec_key(key_id, curve="P-256K", enabled=True, key_operations=["sign","verify"])
    return ec.name

def list_keys_ids():
    keys = key_client.list_properties_of_keys()
    keys_ids = []
    for key in keys:
        keys_ids.append(key.name)
    return keys_ids

def get_specific_json_key(key_id):
    return key_client.get_key(key_id).key

def azure_vault_key_to_pub_key(json_key):
    pubkey = bytearray()
    pubkey.append(0x04)
    pubkey.extend(json_key.x)
    pubkey.extend(json_key.y)
    pubkey = bytes(pubkey)
    return pubkey

def pub_key_to_ethereum_account(pub_key):
    return KeyAPI.PublicKey(public_key_bytes=pub_key).to_checksum_address()

def eth_address_from_hsm(key_id):
    json_key           = get_specific_json_key(key_id)
    pub_key            = azure_vault_key_to_pub_key(json_key)
    return pub_key_to_ethereum_account(pub_key[1:])

print("new_ec_key_pair      :",new_ec_key_pair("single-test"))
print("list_keys_ids        :",list_keys_ids())
print("get_specific_json_key:",get_specific_json_key("single-test"))
print("eth_address_from_hsm :",eth_address_from_hsm("single-test"))


print("\nETH-SIGNER test-run")

def list_eth_signer_accounts():
    return w3.eth.accounts

def get_account_nonce(address):
    return w3.eth.getTransactionCount(address)

def get_gas_price():
    # TODO GasPrice oracle
    gasPrice = w3.eth.gasPrice
    if gasPrice == 0:
        gasPrice = w3.toWei(10,'gwei')
    return gasPrice

def test_regular_tx(user_id):
    address      = eth_address_from_hsm(user_id)
    nonce        = get_account_nonce(address)
    gasPrice     = get_gas_price()

    tx = {
      'from': address,
      'to': address,
      'value': w3.toWei(1, 'ether'),
      'gas': 21000,
      'gasPrice': gasPrice,
      'nonce': nonce,
      'chainId': 172
    }
    return w3.eth.sendTransaction(tx)
    # https://explorer.latam-blockchain.com/tx/0x94f03fabaf8e9c958e4e385774955688b8e1332a3997360287cf87b03af4f672/internal-transactions

def test_erc_transfer(user_id):

    EIP20_ABI    = json.loads('[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}]')
    contract     = w3.eth.contract(address="0xeB5bAB615d63C6980B2b24Fa5C99E11f3bCB79a8", abi=EIP20_ABI) # STAKE ERC677 token on latam-blockchain

    address      = eth_address_from_hsm(user_id)
    nonce        = get_account_nonce(address)
    gasPrice     = get_gas_price()
    amount       = w3.toWei(1, 'ether')

    tx = {
      'from': address,
      'gas': 70000,
      'gasPrice': gasPrice,
      'nonce': nonce,
      'chainId': 172
    }

    tx     = contract.functions.transfer(address, amount).buildTransaction(tx)
    return w3.eth.sendTransaction(tx)
    # https://explorer.latam-blockchain.com/tx/0x3130d6ab340d47b852d3360a86a68f4a0cd142e5f55d40a0091c437b6a5477d7/token-transfers



print("eth_signer_accounts  :",list_eth_signer_accounts())
print("test_regular_tx      :",test_regular_tx(list_keys_ids()[0]).hex())
print("test_erc_transfer    :",test_erc_transfer(list_keys_ids()[0]).hex())
