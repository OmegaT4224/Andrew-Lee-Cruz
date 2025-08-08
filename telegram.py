import json, sys
from base import emit
data=json.load(open(sys.argv[1], 'r', encoding='utf-8'))
for msg in data.get("messages", []):
    txt=msg.get("text", "")
    if isinstance(txt, list): txt="".join([t if isinstance(t,str) else t.get('text','') for t in txt])
    if txt.strip():
        emit("chat","telegram", data.get("name","general"), {"text": txt, "meta": {"from": msg.get("from")}})
print("OK")
