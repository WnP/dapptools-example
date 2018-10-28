# Dapp example

This example provides an introduction to
[dapptools](https://github.com/dapphub/dapptools) and assumes you have some 
knowledge of the Ethereum Virtual Machine and programming in general.

It starts with a simple voting application where candidates are already
defined in the contract.

## Install dapptools

First go to [dapptools web page](https://dapp.tools/) and follow the install
process for dapptools - dapp, seth, solc, hevm adn ethsign - using
the [Nix package manager](https://nixos.org/nix/).

## Initialize your project

```
$ mkdir voting
$ cd voting
$ dapp init
```

At this point you should have a directory structure like the following:

```
voting
├── Makefile
├── lib
│   └── ds-test
│       ├── Dappfile
│       ├── LICENSE
│       ├── Makefile
│       ├── default.nix
│       └── src
│           └── test.sol
└── src
    ├── Voting.sol
    └── Voting.t.sol

```

Where:

- `lib`: directory where external libraries are installed.
- `src`: directory for your source and test files.

## Writting and testing your first Smart Contract

Copy the content of `src/Voting.sol` and `src/Voting.t.sol` from this project
to your own `src` directory.

The code should be self-explanatory, in case your are not familiar with
solidity language you can check out the following resources:

- [The Solidity tutorial](https://ethereumbuilders.gitbooks.io/guide/content/en/solidity_tutorials.html)
- [Solidity documentation](https://solidity.readthedocs.io)

Playing tests with `dapp`:

```console
$ dapp test
```

This command will run the test suite and may  return you errors and warnings.
To be sure, try modifying the source code in order to raise some error or
warning.

In case of test failure your could debug your code using `dapp debug`, eg.:

```console
$ dapp debug out/Voting.t.sol.json
```

Which is a full-featured Solidity debugger. Enjoy!

## Deploying your Smart Contract on geth with dapp testnet

To deploy your contract, first you'll need to build it:

```console
$ dapp build
```

To test your program localy you need an Ethereum test network with some test
accounts, `dapp testnet` is made for that and use
[geth](https://github.com/ethereum/go-ethereum) under the hood.

Launch a test network with 2 accounts:

```console
$ dapp testnet --accounts=2
dapp-testnet:   RPC URL: http://127.0.0.1:8545
dapp-testnet:  TCP port: 38545
dapp-testnet:  Chain ID: 99
dapp-testnet:  Database: /home/scl/.dapp/testnet/8545
dapp-testnet:  Geth log: /home/scl/.dapp/testnet/8545/geth.log
dapp-testnet:   Account: f6b4e49bdc3bd8dbaad4414569c9afd6e1d9de5d (default)
dapp-testnet:   Account: be4e1cc421e8a8da3af06bd0b99517a1745d4c01
```

I highly recommend opening another terminal to also watch `geth` logs:

```console
$ tail -f ~/.dapp/testnet/8545/geth.log
```

To interact with `geth` we are going to use [seth](https://dapp.tools/seth/)
which is a powerfull command line utility interacting with Ethereum.

You can find more information about `seth` in the
[seth README on github](https://github.com/dapphub/dapptools/blob/master/src/seth/README.md).

Set the following environment variables:

```console
$ # Set an address as the default sender. Retrieved from `dapp testnet` output
$ ETH_FROM=0xf6b4e49bdc3bd8dbaad4414569c9afd6e1d9de5d
$ # Test RPC network endpoint
$ ETH_RPC_URL=http://127.0.0.1:8545
$ # Yes, you need to be explicite
$ ETH_RPC_ACCOUNTS=yes
```
You can now use `seth ls` to see your accounts' balances.

The first thing you should do is to create a transaction, because `geth`
dev mode node **only** mines if there are transactions.
[See this geth issue](https://github.com/ethereum/go-ethereum/issues/15646) for
more info.
**If you don't do that transactions are going to fail**.

So send 1 wei - the smallest Ethereum unit - to your second test account:

```console
$ seth send --value 1 0xbe4e1cc421e8a8da3af06bd0b99517a1745d4c01
```

You can use `seth ls` again to see your accounts' balances. And notice that
there are no transaction fees.

Once done you can estimate the gas cost of your contract deployment:

```console
$ seth estimate --create out/Voting.bin 0x  # Yes 0x is mandatory
385310
```

Now you can send your smart contract with the correct gas:

```console
$ ETH_GAS=500000 seth send --create out/Voting.bin
seth-send: Published transaction with 1169 bytes of calldata.
seth-send: 0x222b6a3b6e2ee5529b8973b18df62a3bb8864c2552cf94173e8fabf3649aca57
seth-send: Waiting for transaction receipt...
seth-send: Transaction included in block 21.
0xaba9fa09fc217ab0d65e4f098b0c56136b360a8e
```

Great job!

## Playing with your Smart Contract using seth

Because working with hex data value is not that pleasant, let's set some
environment variables in order to play your Smart Contract:

```console
$ CONTRACT=0xaba9fa09fc217ab0d65e4f098b0c56136b360a8e
```

Our API expose 2 functions with the following signatures:

```Solidity
function total_for(bytes32 candidate) public view returns (uint256)
function vote_for(bytes32 candidate) public
```

Both takes a `bytes32` as first arguments, so we need to convert `ascii` to
`hex data` and then to `bytes32`, thanks to `seth` which provides utilities
to deal with that, eg.:

```console
$ seth --from-ascii $STEEVE  # ASCII to hex data
0x537465657665
$ seth --to-bytes32 0x537465657665
5374656576650000000000000000000000000000000000000000000000000000
```

You can write that as a one-liner and set it to environment variables for every
candidates:

```console
$ STEEVE=`seth --to-bytes3 $(seth --from-ascii Steeve)`
$ BOB=`seth --to-bytes3 $(seth --from-ascii Bob)`
$ ALICE=`seth --to-bytes3 $(seth --from-ascii Alice)`
```

You can also add an unknown candidate for testing purposes:

```console
$ UNKNOWN=`seth --to-bytes3 $(seth --from-ascii Unknown)`
```

Now let's call our contract **without updating the blockchain**,

Note that `seth` use the following syntax for function signature:

```
<function_name>([arguments_types])([return_types])
```

First, let's try to vote for an unknown user:

```console
$ seth call $CONTACT "vote_for(bytes32)" $UNKNOWN
0x08c379a000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000011496e76616c69642063616e646964617465000000000000000000000000000000
```

Yes, return value are also in hex data, but you can use `--to-ascii` to fix
this:

```console
$ seth --to-ascii $(seth call $CONTACT "vote_for(bytes32)" $UNKNOWN)
y Invalid candidate
```

Nice, looks like it works!

Now try with a real user:

```console
$ seth --to-ascii $(seth call $CONTACT "vote_for(bytes32)" $STEEVE)
```

Now let's query `total_for`, note that we are using `--to-uint256` here because
`total_for` returns an `uint256`:

```console
$ seth --to-uint256 $(seth call $CONTACT "total_for(bytes32)" $STEEVE)
0000000000000000000000000000000000000000000000000000000000000000
```

Sounds weird at first... But, remember that `seth call` calls our contract
**without updating the blockchain**.

Now that we know what we're doing, we can make a real call to our test RPC
server using `seth send`:

```console
$ seth send $CONTACT "vote_for(bytes32)" $STEEVE
seth-send: warning: `ETH_GAS' not set; using default gas amount
seth-send: Published transaction with 36 bytes of calldata.
seth-send: 0xbcd96d482046cf49440c0a6397f11e2b676162463f0841276455e2ad3a3de16c
seth-send: Waiting for transaction receipt...
seth-send: Transaction included in block 9.
```

And then:

```console
$ seth --to-uint256 $(seth call $CONTACT "total_for(bytes32)" $STEEVE)
0000000000000000000000000000000000000000000000000000000000000001
```

![Magic!!!](https://i.giphy.com/ujUdrdpX7Ok5W.gif)
