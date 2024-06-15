# Baptswap Coin Deployer V1

## Setup

### Move package
- initialize the aptos: `aptos init`
    - choose the desired network and provide the `BAPT_FRAMEWORK_PRIV_KEY`
- compile and publish the modules: `aptos move publish --profile yourprofile`
- run the script to initialize the module: `aptos move run-script --compiled-script-path build/coin-deployer/bytecode_scripts/init.mv --profile default --args u64:200000000 address:0xc1f80cf284c8db6a1c03ad29bc93d6cdc10e61ff39ffd24c66fb51dfbacfbe49`

This publishes the `Deployer` module under the `BAPT_FRAMEWORK_ADDRESS`
