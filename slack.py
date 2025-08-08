import json, sys, glob
from base import emit
for p in glob.glob(sys.argv[1]):
    data=json.load(open(p, 'r', encoding='utf-8'))
    channel=data.get("channel","general")
    for m in data.get("messages",[]):
        txt=m.get("text","")
        if txt.strip():
            emit("chat","slack", channel, {"text": txt, "meta": {"user": m.get("user")}})
print("OK")
