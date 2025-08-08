import json, time, hmac, hashlib, requests, sys
UID="ALC-ROOT-1010-1111-XCOV∞"
KEY=hashlib.sha3_256((UID+"::QEL").encode()).hexdigest().encode()
HUB=os.getenv("HUB_URL","http://localhost:8080/ingest")

def sign(obj):
    body=json.dumps(obj, separators=(',',':'), sort_keys=True).encode()
    return hmac.new(KEY, body, hashlib.sha3_256).hexdigest()

def emit(kind, source, project, payload):
    evt={"type":"omni.event","uid":UID,"kind":kind,"source":source,"project":project,
         "ts":int(time.time()),"nonce":int(time.time()*1000)%2**32,"payload":payload}
    evt["sig"]=sign(evt)
    r=requests.post(HUB, json=evt, timeout=30)
    r.raise_for_status()
