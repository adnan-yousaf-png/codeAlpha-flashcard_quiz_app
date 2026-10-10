from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .routers import decks, flashcards, quiz

# Ensure all database tables exist
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="FlashLearn API",
    description="Backend service for Flashcard Quiz App with SQLite & SQLAlchemy",
    version="1.0.0"
)

# Enable CORS for Flutter Web, mobile emulators, and local clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register route modules
app.include_router(decks.router)
app.include_router(flashcards.router)
app.include_router(quiz.router)

@app.get("/")
def root():
    return {
        "message": "FlashLearn API is running smoothly",
        "docs_url": "/docs",
        "health": "healthy"
    }
