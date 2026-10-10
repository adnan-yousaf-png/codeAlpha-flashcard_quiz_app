from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field

# --- Deck Schemas ---
class DeckBase(BaseModel):
    name: str = Field(..., max_length=100)
    description: Optional[str] = Field(None, max_length=255)
    category: Optional[str] = Field("Mobile Core Dev", max_length=50)

class DeckCreate(DeckBase):
    pass

class DeckResponse(DeckBase):
    id: int
    created_at: datetime
    card_count: int = 0
    mastered_count: int = 0

    class Config:
        from_attributes = True

class DeckStatsResponse(BaseModel):
    total_cards: int
    mastered_cards: int
    needs_review_cards: int
    streak_days: int = 4

# --- Flashcard Schemas ---
class FlashcardBase(BaseModel):
    question: str = Field(..., min_length=1, max_length=200, description="Question text up to 200 chars")
    answer: str = Field(..., min_length=1, max_length=300, description="Answer text up to 300 chars")
    category: Optional[str] = Field("Flutter UI", max_length=50)

class FlashcardCreate(FlashcardBase):
    deck_id: int

class FlashcardUpdate(BaseModel):
    question: Optional[str] = Field(None, min_length=1, max_length=200)
    answer: Optional[str] = Field(None, min_length=1, max_length=300)
    category: Optional[str] = Field(None, max_length=50)
    is_favorite: Optional[bool] = None
    mastery_percentage: Optional[int] = Field(None, ge=0, le=100)

class FlashcardGradeRequest(BaseModel):
    grade: str = Field(..., description="Again, Hard, Good, Easy")

class FlashcardResponse(FlashcardBase):
    id: int
    deck_id: int
    is_favorite: bool
    mastery_percentage: int
    difficulty_interval: str
    last_studied_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

# --- Quiz Schemas ---
class QuizQuestionResponse(BaseModel):
    id: int
    question: str
    category: str
    options: List[str]

class QuizAnswerSubmission(BaseModel):
    card_id: int
    selected_option: str

class QuizSubmissionRequest(BaseModel):
    deck_id: int
    answers: List[QuizAnswerSubmission]

class QuizResultCard(BaseModel):
    card_id: int
    question: str
    selected_option: str
    correct_answer: str
    is_correct: bool

class QuizResultResponse(BaseModel):
    total_questions: int
    correct_answers: int
    score_percentage: float
    results: List[QuizResultCard]
