import os, json, time, hashlib, requests
from web3 import Web3

RPC=os.getenv("CHAIN_RPC")
VAULT=os.getenv("ROYALTY_VAULT")
RELAYER=os.getenv("RELAYER_KEY")
REFLECT=os.getenv("REFLECT_GATEWAY","")

w3 = Web3(Web3.HTTPProvider(RPC)) if RPC else None
acct = w3.eth.account.from_key(RELAYER) if (w3 and RELAYER) else None

ABI = json.load(open("contracts/RoyaltyVault.abi.json")) if os.path.exists("contracts/RoyaltyVault.abi.json") else []
vault = w3.eth.contract(address=w3.to_checksum_address(VAULT), abi=ABI) if (w3 and VAULT and ABI) else None

def _send(tx):
    tx.update({"from": acct.address, "nonce": w3.eth.get_transaction_count(acct.address),
               "chainId": w3.eth.chain_id, "maxFeePerGas": w3.to_wei("30","gwei"),
               "maxPriorityFeePerGas": w3.to_wei("1.5","gwei")})
    stx = acct.sign_transaction(tx)
    return w3.eth.send_raw_transaction(stx.rawTransaction).hex()

def deposit_eth(amount_eth: float):
    return _send({"to": vault.address, "value": w3.to_wei(amount_eth,"ether"), "data": b""})

def close_epoch():
    return _send(vault.functions.closeEpochAndAllocate().build_transaction({}))

def reflect_notarize(evt):
    if not REFLECT: return None
    try:
        # Minimal example: post JSON; replace with your gateway's schema
        r = requests.post(REFLECT, json={"event": evt, "hash": hashlib.sha3_256(json.dumps(evt, sort_keys=True).encode()).hexdigest()}, timeout=10)
        return r.json()
    except Exception:
        return None

def handle_event(evt):
    kind = evt.get("kind")
    if kind == "royalty_in" and vault is not None:
        usd = float(evt["data"]["usd"])
        eth_price = float(evt["data"]["eth_price"])
        amt = usd / eth_price if eth_price>0 else 0.0
        txh = deposit_eth(amt)
        evt["onchain_deposit"] = txh
        time.sleep(12)
        evt["onchain_close"] = close_epoch()
        evt["reflect"] = reflect_notarize(evt)
        return True
    elif kind in ("chat","doc","automation","alert","command"):
        evt["reflect"] = reflect_notarize(evt)
        return True
    return False
