from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Boolean, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from .database import Base

def get_utc_now():
    return datetime.now(timezone.utc)

class Deck(Base):
    __tablename__ = "decks"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(String(255), nullable=True)
    category = Column(String(50), default="Mobile Core Dev")
    created_at = Column(DateTime, default=get_utc_now)

    # Relationships
    flashcards = relationship("Flashcard", back_populates="deck", cascade="all, delete-orphan")
    quiz_attempts = relationship("QuizAttempt", back_populates="deck", cascade="all, delete-orphan")

class Flashcard(Base):
    __tablename__ = "flashcards"

    id = Column(Integer, primary_key=True, index=True)
    deck_id = Column(Integer, ForeignKey("decks.id", ondelete="CASCADE"), nullable=False)
    question = Column(String(200), nullable=False)
    answer = Column(String(300), nullable=False)
    category = Column(String(50), default="Flutter UI")
    is_favorite = Column(Boolean, default=False)
    mastery_percentage = Column(Integer, default=0)
    difficulty_interval = Column(String(20), default="1d") # e.g. '<1m', '10m', '1d', '4d'
    last_studied_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=get_utc_now)

    # Relationship
    deck = relationship("Deck", back_populates="flashcards")

class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"

    id = Column(Integer, primary_key=True, index=True)
    deck_id = Column(Integer, ForeignKey("decks.id", ondelete="CASCADE"), nullable=False)
    total_questions = Column(Integer, nullable=False)
    correct_answers = Column(Integer, nullable=False)
    score_percentage = Column(Float, nullable=False)
    completed_at = Column(DateTime, default=get_utc_now)

    # Relationship
    deck = relationship("Deck", back_populates="quiz_attempts")
