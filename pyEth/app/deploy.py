import json
import web3

from web3 import Web3
from solc import compile_source
from web3.contract import ConciseContract

# Solidity contract
solcontract = open('./contracts/CustodianConsent.sol','r').read()
solcompiled = compile_source(solcontract)
solinterface = solcompiled['<stdin>:CustodianConsent']

# web3.py instance
w3 = Web3(Web3.EthereumTesterProvider())

# set pre-funded account as sender
w3.eth.defaultAccount = w3.eth.accounts[0]

# Instantiate and deploy contract
CustodianConsent = w3.eth.contract(abi=solinterface['abi'], bytecode=solinterface['bin'])

# All accounts
accounts = w3.eth.accounts
account = w3.eth.accounts[1]

# Submit the transaction that deploys the contract
transhash = CustodianConsent.constructor().transact()
transreceipt = w3.eth.waitForTransactionReceipt(transhash) # mining

# Create the contract instance with the newly-deployed address
chan = w3.eth.contract(
    address=transreceipt.contractAddress,
    abi=solinterface['abi'],
)

# Print something to make sure it compiled
#print('killtest: {}'.format(
#    chan.functions.kill(account).call()
#))

# Wait for transaction
w3.eth.waitForTransactionReceipt(transhash)

# When issuing a lot of reads, try this more concise reader:
#reader = ConciseContract(chan)
#assert reader.greet() == "Nihao"
