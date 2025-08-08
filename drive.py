# Placeholder: expects a directory scan with extracted text files (.txt) representing docs
import sys, os
from base import emit
root=sys.argv[1]
for dirpath, _, files in os.walk(root):
    for fn in files:
        if fn.lower().endswith(".txt"):
            path=os.path.join(dirpath, fn)
            txt=open(path,'r',encoding='utf-8', errors='ignore').read()
            if txt.strip():
                emit("doc","drive","general", {"text": txt, "meta":{"path": path}})
print("OK")
