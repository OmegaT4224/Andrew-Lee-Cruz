#!/usr/bin/env python3
import os, sys, time, json, hashlib

UID="ALC-ROOT-1010-1111-XCOV∞"
def sha3(x: bytes) -> str:
    return hashlib.sha3_256(x).hexdigest()

def notarize(path: str):
    with open(path, "rb") as f:
        h = sha3(f.read())
    event = {"uid": UID, "ts": int(time.time()), "artifact": os.path.basename(path), "hash": h, "block": "DRGN_REFLECT_000"}
    out = f"{path}.notarized.json"
    with open(out, "w", encoding="utf-8") as g:
        json.dump(event, g, indent=2)
    print(out)

if __name__=="__main__":
    if len(sys.argv) < 2:
        print("Usage: notarize_event.py <file>")
        sys.exit(1)
    notarize(sys.argv[1])
