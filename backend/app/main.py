from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.ingredients import router as ingredients_router

app = FastAPI(title="Sips254 AI Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten before production
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ingredients_router)


@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "sips254-ai"}