```bash

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

```


