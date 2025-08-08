import json, sys, os
from base import emit
data=json.load(open(sys.argv[1], 'r', encoding='utf-8'))
for conv in data.get("conversations", []):
    title=conv.get("title","general")
    for node in conv.get("mapping", {}).values():
        msg=node.get("message")
        if not msg: continue
        content=msg.get("content",{}).get("parts",[])
        if not content: continue
        text="\n".join(content)
        emit("chat","chatgpt", title, {"text": text, "meta": {"role": msg.get("author",{}).get("role")}})
print("OK")
