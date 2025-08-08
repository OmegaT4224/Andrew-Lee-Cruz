import os, json, hmac, hashlib, time
from typing import Dict, Any
from fastapi import FastAPI, Request, HTTPException
from redis import Redis
from rq import Queue
from chromadb import Client
from chromadb.config import Settings

app = FastAPI()
REDIS_URL=os.getenv("REDIS_URL","redis://localhost:6379/0")
r = Redis.from_url(REDIS_URL)
q = Queue("axiomaf", connection=r)

UID="ALC-ROOT-1010-1111-XCOV∞"
KEY=hashlib.sha3_256((UID+"::QEL").encode()).hexdigest().encode()

# Vector store
chroma = Client(Settings(anonymized_telemetry=False, persist_directory="/app/chroma"))
if "axiomaf-index" not in [c.name for c in chroma.list_collections()]:
    chroma.create_collection("axiomaf-index")
index = chroma.get_collection("axiomaf-index")

def verify(payload: Dict[str, Any]) -> bool:
    sig = payload.get("sig","")
    body = {k:payload[k] for k in sorted(payload) if k!="sig"}
    mac = hmac.new(KEY, json.dumps(body, separators=(',',':')).encode(), hashlib.sha3_256).hexdigest()
    return hmac.compare_digest(sig, mac)

def embed_and_store(doc: str, meta: Dict[str, Any]):
    # Simple embedding via hashing fallback (replace with real embeddings if desired)
    # Chroma requires embeddings; we'll use a deterministic dummy vector (not ideal for prod).
    vec = [int(hashlib.sha256(doc.encode()).hexdigest()[i:i+8],16)%1000/1000.0 for i in range(0,32,8)]
    index.add(documents=[doc], metadatas=[meta], ids=[str(int(time.time()*1000))], embeddings=[vec])

@app.post("/ingest")
async def ingest(req: Request):
    data = await req.json()
    if not verify(data):
        raise HTTPException(403, "bad sig")
    kind = data.get("kind")
    q.enqueue("jobs.handle_event", data, job_timeout=300)
    # For chats/docs, index immediately
    if kind in ("chat","doc"):
        payload = data.get("payload",{})
        text = payload.get("text","")
        if text.strip():
            embed_and_store(text, {"source": data.get("source"), "project": data.get("project"), "ts": data.get("ts")})
    return {"ok": True}

@app.get("/search")
async def search(qs: str, project: str = "general", n: int = 5):
    # naive search: filter by project meta and return most recent n (chroma similarity omitted for lightweight)
    results = index.get()
    items = []
    if results and results["documents"]:
        for doc, meta in zip(results["documents"], results["metadatas"]):
            if meta and meta.get("project")==project and qs.lower() in doc.lower():
                items.append({"text": doc[:512], "meta": meta})
    items = sorted(items, key=lambda x: x["meta"]["ts"], reverse=True)[:n]
    return {"results": items}
