import uvicorn
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from websocket.stream_handler import handle_voice_translation_stream

app = FastAPI(
    title="Sinhala-to-Tamil Live AI Voice Translation Backend",
    description="Low-latency WebSocket streaming server powered by Gemini Multimodal Live API."
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # In development, allow all connections
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    """Simple HTTP route for M7 to verify the backend container status is green."""
    return {"status": "healthy", "service": "sinhala-tamil-voice-backend", "day": 1}

@app.websocket("/translate-stream")
async def websocket_endpoint(websocket: WebSocket):
    """
    The main architectural WebSocket highway.
    Passes the socket context seamlessly to Member 4's handler module.
    """
    await handle_voice_translation_stream(websocket)

if __name__ == "__main__":
    # Runs the local loop server on Port 8000
    # Bound to 0.0.0.0 so M7's Nginx/Docker configs can see it flawlessly
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)