# TODO
**Warning dont use this terraform script for production by any chance eth-signer listening at 0.0.0.0 by now**
- create a private network for key management
- include private net in eth-signer container
- create shared storage creation
- include shared storage in the eth-signer container
   

# debug

## Chek the eth-signer container info
```bash
cointigo@nixbox2:~/nft$ az container list
```

## Check eth-siger conatiner logs

```bash
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

```bash
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

# check ethereum accounts on eth-signer
root@SandboxHost-637700298678944975:/opt/ethsigner# curl --location --request POST 'http://127.0.0.1:8545' --header 'Content-Type: application/json' --data-raw '{  "jsonrpc":"2.0", "method":"eth_accounts", "params":[], "id":1 }'
```
