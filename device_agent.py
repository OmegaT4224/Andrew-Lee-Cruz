import os, time, json, hmac, hashlib, requests, subprocess
UID="ALC-ROOT-1010-1111-XCOV∞"; HUB=os.getenv("AX_HUB","http://localhost:8080")
KEY=hashlib.sha3_256((UID+"::QEL").encode()).hexdigest().encode()

def sign(d:dict)->str:
    body=json.dumps(d, separators=(',',':'), sort_keys=True).encode()
    return hmac.new(KEY, body, hashlib.sha3_256).hexdigest()

def battery():
    try:
        o=subprocess.check_output(["termux-battery-status"]); 
        return json.loads(o)
    except Exception:
        return {}
def push(kind,data):
    payload={"type":"omni.event","uid":UID,"kind":kind,"source":"s24-ultra","project":"general","ts":int(time.time()),"nonce":int(time.time()*1000)%2**32,"payload":data}
    payload["sig"]=sign(payload)
    requests.post(f"{HUB}/ingest", json=payload, timeout=10).raise_for_status()

def daemon():
    while True:
        try:
            push("heartbeat", {"battery": battery()})
        except Exception: pass
        time.sleep(30)

if __name__=="__main__": daemon()
