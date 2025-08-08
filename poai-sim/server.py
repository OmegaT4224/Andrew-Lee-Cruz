#!/usr/bin/env python3
"""
VIOLET-AF PoAI Simulator Server

FastAPI-based simulation environment for testing PoAI computations and device behavior

Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
License: UCL-∞
"""

import asyncio
import json
import time
import hashlib
import secrets
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from datetime import datetime, timezone

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
import uvicorn

# Constants
CREATOR_UID = "ALC-ROOT-1010-1111-XCOV∞"
CREATOR_EMAIL = "allcatch37@gmail.com"
CREATOR_ORCID = "0009-0000-3695-1084"

# Data Models
@dataclass
class SimulatedDevice:
    device_id: str
    name: str
    is_online: bool
    battery_level: int
    is_charging: bool
    cpu_temperature: float
    screen_on: bool
    last_poai_submission: int
    total_submissions: int
    energy_compliant: bool
    attestation_valid: bool
    location: str = "Simulated"

@dataclass
class PoAISubmission:
    device_id: str
    digest: str
    signature: str
    timestamp: int
    energy_compliant: bool
    attestation_token: Optional[str] = None

class DeviceUpdate(BaseModel):
    device_id: str
    battery_level: Optional[int] = None
    is_charging: Optional[bool] = None
    cpu_temperature: Optional[float] = None
    screen_on: Optional[bool] = None

class PoAIRequest(BaseModel):
    device_id: str
    input_data: str
    force_computation: bool = False

# Application setup
app = FastAPI(
    title="VIOLET-AF PoAI Simulator",
    description="Development and testing environment for Proof-of-AI computations",
    version="1.0.0"
)

# Serve static files for the UI
app.mount("/static", StaticFiles(directory="ui"), name="static")

# Global state
devices: Dict[str, SimulatedDevice] = {}
submissions: List[PoAISubmission] = []
connected_clients: List[WebSocket] = []

# Initialize mock devices
def initialize_mock_devices():
    mock_devices = [
        SimulatedDevice(
            device_id="SIM_GALAXY_S24_001",
            name="Samsung Galaxy S24 Ultra",
            is_online=True,
            battery_level=87,
            is_charging=True,
            cpu_temperature=36.5,
            screen_on=False,
            last_poai_submission=int(time.time()) - 120,
            total_submissions=156,
            energy_compliant=True,
            attestation_valid=True
        ),
        SimulatedDevice(
            device_id="SIM_IPHONE_15_002",
            name="iPhone 15 Pro Max",
            is_online=True,
            battery_level=73,
            is_charging=False,
            cpu_temperature=41.2,
            screen_on=False,
            last_poai_submission=int(time.time()) - 300,
            total_submissions=98,
            energy_compliant=True,
            attestation_valid=True
        ),
        SimulatedDevice(
            device_id="SIM_PIXEL_8_003",
            name="Google Pixel 8 Pro",
            is_online=False,
            battery_level=42,
            is_charging=False,
            cpu_temperature=38.0,
            screen_on=True,
            last_poai_submission=int(time.time()) - 1800,
            total_submissions=67,
            energy_compliant=False,
            attestation_valid=True
        ),
        SimulatedDevice(
            device_id="SIM_ONEPLUS_11_004",
            name="OnePlus 11",
            is_online=True,
            battery_level=91,
            is_charging=True,
            cpu_temperature=34.8,
            screen_on=False,
            last_poai_submission=int(time.time()) - 90,
            total_submissions=203,
            energy_compliant=True,
            attestation_valid=True
        )
    ]
    
    for device in mock_devices:
        devices[device.device_id] = device

# Energy policy checker
def check_energy_policy(device: SimulatedDevice) -> bool:
    battery_ok = device.is_charging or device.battery_level > 70
    temp_ok = device.cpu_temperature < 45.0
    screen_ok = not device.screen_on
    
    return battery_ok and temp_ok and screen_ok and device.is_online

# PoAI computation simulator
def simulate_poai_computation(device_id: str, input_data: str) -> PoAISubmission:
    # Create deterministic digest based on input and device
    digest_input = f"{input_data}|{device_id}|{CREATOR_UID}|{int(time.time())}"
    digest = hashlib.sha256(digest_input.encode()).hexdigest()
    
    # Simulate signature (would be hardware-backed in real implementation)
    signature = hashlib.sha256(f"signature_{digest}_{device_id}".encode()).hexdigest()
    
    device = devices.get(device_id)
    energy_compliant = check_energy_policy(device) if device else False
    
    submission = PoAISubmission(
        device_id=device_id,
        digest=digest,
        signature=signature,
        timestamp=int(time.time()),
        energy_compliant=energy_compliant,
        attestation_token=f"sim_attestation_{secrets.token_hex(16)}"
    )
    
    return submission

# WebSocket connection manager
async def broadcast_update(data: Dict[str, Any]):
    if connected_clients:
        message = json.dumps(data)
        disconnected = []
        for client in connected_clients:
            try:
                await client.send_text(message)
            except:
                disconnected.append(client)
        
        # Remove disconnected clients
        for client in disconnected:
            connected_clients.remove(client)

# API Routes
@app.get("/", response_class=HTMLResponse)
async def serve_ui():
    """Serve the main UI"""
    try:
        with open("ui/index.html", "r") as f:
            return f.read()
    except FileNotFoundError:
        return """
        <html>
        <head><title>VIOLET-AF PoAI Simulator</title></head>
        <body>
        <h1>VIOLET-AF PoAI Simulator</h1>
        <p>UI files not found. Please ensure ui/index.html exists.</p>
        <p>API Documentation: <a href="/docs">/docs</a></p>
        </body>
        </html>
        """

@app.get("/api/devices")
async def get_devices():
    """Get all simulated devices"""
    return {
        "devices": [asdict(device) for device in devices.values()],
        "total_devices": len(devices),
        "online_devices": len([d for d in devices.values() if d.is_online]),
        "energy_compliant": len([d for d in devices.values() if d.energy_compliant])
    }

@app.get("/api/devices/{device_id}")
async def get_device(device_id: str):
    """Get specific device details"""
    if device_id not in devices:
        raise HTTPException(status_code=404, detail="Device not found")
    
    device = devices[device_id]
    return {
        "device": asdict(device),
        "energy_policy": {
            "meets_requirements": check_energy_policy(device),
            "battery_ok": device.is_charging or device.battery_level > 70,
            "temperature_ok": device.cpu_temperature < 45.0,
            "screen_ok": not device.screen_on,
            "online_ok": device.is_online
        }
    }

@app.put("/api/devices/{device_id}")
async def update_device(device_id: str, update: DeviceUpdate):
    """Update device parameters"""
    if device_id not in devices:
        raise HTTPException(status_code=404, detail="Device not found")
    
    device = devices[device_id]
    
    if update.battery_level is not None:
        device.battery_level = max(0, min(100, update.battery_level))
    if update.is_charging is not None:
        device.is_charging = update.is_charging
    if update.cpu_temperature is not None:
        device.cpu_temperature = max(20.0, min(80.0, update.cpu_temperature))
    if update.screen_on is not None:
        device.screen_on = update.screen_on
    
    # Update energy compliance
    device.energy_compliant = check_energy_policy(device)
    
    # Broadcast update to connected clients
    await broadcast_update({
        "type": "device_update",
        "device_id": device_id,
        "device": asdict(device)
    })
    
    return {"success": True, "device": asdict(device)}

@app.post("/api/poai/submit")
async def submit_poai(request: PoAIRequest):
    """Submit a PoAI computation"""
    if request.device_id not in devices:
        raise HTTPException(status_code=404, detail="Device not found")
    
    device = devices[request.device_id]
    
    # Check energy policy unless forced
    if not request.force_computation and not check_energy_policy(device):
        raise HTTPException(
            status_code=400, 
            detail="Device does not meet energy policy requirements"
        )
    
    # Simulate computation
    submission = simulate_poai_computation(request.device_id, request.input_data)
    submissions.append(submission)
    
    # Update device stats
    device.last_poai_submission = submission.timestamp
    device.total_submissions += 1
    
    # Broadcast update
    await broadcast_update({
        "type": "poai_submission",
        "submission": asdict(submission),
        "device_id": request.device_id
    })
    
    return {
        "success": True,
        "submission": asdict(submission),
        "device_stats": {
            "total_submissions": device.total_submissions,
            "last_submission": device.last_poai_submission
        }
    }

@app.get("/api/poai/submissions")
async def get_submissions(limit: int = 20):
    """Get recent PoAI submissions"""
    recent_submissions = sorted(submissions, key=lambda x: x.timestamp, reverse=True)[:limit]
    return {
        "submissions": [asdict(s) for s in recent_submissions],
        "total_submissions": len(submissions)
    }

@app.get("/api/status")
async def get_status():
    """Get overall system status"""
    online_devices = [d for d in devices.values() if d.is_online]
    energy_compliant = [d for d in devices.values() if d.energy_compliant]
    recent_submissions = len([s for s in submissions if s.timestamp > time.time() - 3600])
    
    return {
        "system": {
            "name": "VIOLET-AF PoAI Simulator",
            "version": "1.0.0",
            "creator_uid": CREATOR_UID,
            "uptime": int(time.time())
        },
        "devices": {
            "total": len(devices),
            "online": len(online_devices),
            "energy_compliant": len(energy_compliant)
        },
        "submissions": {
            "total": len(submissions),
            "last_hour": recent_submissions
        },
        "timestamp": int(time.time())
    }

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time updates"""
    await websocket.accept()
    connected_clients.append(websocket)
    
    try:
        # Send initial data
        await websocket.send_text(json.dumps({
            "type": "initial_data",
            "devices": [asdict(device) for device in devices.values()],
            "submissions": [asdict(s) for s in submissions[-10:]]
        }))
        
        # Keep connection alive and handle incoming messages
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            
            # Handle different message types
            if message.get("type") == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))
                
    except WebSocketDisconnect:
        connected_clients.remove(websocket)

# Background task to simulate device behavior
async def simulate_device_behavior():
    """Simulate realistic device behavior changes"""
    while True:
        await asyncio.sleep(30)  # Update every 30 seconds
        
        for device in devices.values():
            if device.is_online:
                # Simulate battery drain/charge
                if device.is_charging:
                    device.battery_level = min(100, device.battery_level + 1)
                else:
                    device.battery_level = max(0, device.battery_level - 1)
                
                # Simulate temperature fluctuations
                device.cpu_temperature += (secrets.randbelow(20) - 10) / 10.0
                device.cpu_temperature = max(25.0, min(60.0, device.cpu_temperature))
                
                # Update energy compliance
                old_compliant = device.energy_compliant
                device.energy_compliant = check_energy_policy(device)
                
                # Broadcast if compliance changed
                if old_compliant != device.energy_compliant:
                    await broadcast_update({
                        "type": "energy_policy_change",
                        "device_id": device.device_id,
                        "energy_compliant": device.energy_compliant
                    })

@app.on_event("startup")
async def startup_event():
    """Initialize the simulator"""
    initialize_mock_devices()
    # Start background simulation
    asyncio.create_task(simulate_device_behavior())

if __name__ == "__main__":
    uvicorn.run(
        "server:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )