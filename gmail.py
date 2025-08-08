# Minimal mbox to text adapter placeholder: expects pre-parsed JSON lines with 'subject' and 'body'
import sys, json
from base import emit
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    for line in f:
        try:
            msg=json.loads(line)
            body=(msg.get("subject","") + "\n" + msg.get("body","")).strip()
            if body:
                emit("doc","gmail","general", {"text": body, "meta":{"from": msg.get("from"), "date": msg.get("date")}})
        except: pass
print("OK")
