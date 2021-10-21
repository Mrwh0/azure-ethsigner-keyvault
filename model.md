```bash
# base contracts ownership

remplace the contract Hardware Wallet ownership to 3 of 5 multisig using app.gnosis-safe.io

sign contract creation or tranfer ownership to a multisig wallet.
```



```bash
# Key Management

new user 
   |
   |                    
base app --> new user UUID --> create new wallet task                                                 



user contract interaction
   |
   |
base app --> raw tx --> eth-signer (sign and broadcast) 



create new wallet task:

- create new EC key on HSM
- backup new HSM key
- create .toml file on eth-signer shared storage
- on WIP update/reload/restart eth-signer account to be used as signer account
- return eth address(account) 


notes:
- the base app should be able to use the eth-signer endpoint as web3 signer provider & broadcast only, for all other web3 methods needed such as events listen, gas information, balances etc ...  use another rpc endpoint.  
- a gas price oracle must be implemented or find a 3rd party service
- a tx fees protocol on the base app side (each user wallet will hold balance to pay for tx fees?)
- find a 3rd party service for the RPC endpoint for web3 (non signature & broadcast related) methods
```


