from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from ..database import get_db
from ..models import Deck, Flashcard
from ..schemas import FlashcardCreate, FlashcardUpdate, FlashcardResponse, FlashcardGradeRequest

router = APIRouter(prefix="/api/flashcards", tags=["Flashcards"])

@router.get("", response_model=List[FlashcardResponse])
def get_flashcards(
    deck_id: Optional[int] = Query(None, description="Filter by deck ID"),
    category: Optional[str] = Query(None, description="Filter by category name"),
    filter_type: Optional[str] = Query("all", description="all, recent, favorites, mastered"),
    search: Optional[str] = Query(None, description="Search term in question or answer"),
    db: Session = Depends(get_db)
):
    """Retrieve flashcards matching criteria with sorting and filters."""
    query = db.query(Flashcard)

    if deck_id is not None:
        query = query.filter(Flashcard.deck_id == deck_id)

    if category and category.lower() != "all":
        query = query.filter(Flashcard.category.ilike(f"%{category}%"))

    if search:
        search_pattern = f"%{search.strip()}%"
        query = query.filter(
            or_(
                Flashcard.question.ilike(search_pattern),
                Flashcard.answer.ilike(search_pattern),
                Flashcard.category.ilike(search_pattern)
            )
        )

    # Filter chips
    if filter_type == "favorites":
        query = query.filter(Flashcard.is_favorite == True)
    elif filter_type == "mastered":
        query = query.filter(Flashcard.mastery_percentage >= 80)
    elif filter_type == "recent":
        # Order by last studied or created recently
        query = query.order_by(Flashcard.last_studied_at.desc().nullslast(), Flashcard.id.desc())
    else:
        query = query.order_by(Flashcard.id.asc())

    return query.all()

@router.get("/{card_id}", response_model=FlashcardResponse)
def get_flashcard(card_id: int, db: Session = Depends(get_db)):
    """Retrieve single flashcard by ID."""
    card = db.query(Flashcard).filter(Flashcard.id == card_id).first()
    if not card:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Flashcard not found")
    return card

@router.post("", response_model=FlashcardResponse, status_code=status.HTTP_201_CREATED)
def create_flashcard(card_in: FlashcardCreate, db: Session = Depends(get_db)):
    """Create a new flashcard with prompt validation."""
    if not card_in.question.strip():
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Question cannot be empty")
    if not card_in.answer.strip():
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Answer cannot be empty")

    deck = db.query(Deck).filter(Deck.id == card_in.deck_id).first()
    if not deck:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Deck with id {card_in.deck_id} does not exist")

    card = Flashcard(
        deck_id=card_in.deck_id,
        question=card_in.question.strip(),
        answer=card_in.answer.strip(),
        category=card_in.category or "Flutter UI",
        is_favorite=False,
        mastery_percentage=0,
        difficulty_interval="1d"
    )
    db.add(card)
    db.commit()
    db.refresh(card)
    return card

@router.put("/{card_id}", response_model=FlashcardResponse)
def update_flashcard(card_id: int, card_in: FlashcardUpdate, db: Session = Depends(get_db)):
    """Update flashcard fields."""
    card = db.query(Flashcard).filter(Flashcard.id == card_id).first()
    if not card:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Flashcard not found")

    if card_in.question is not None:
        if not card_in.question.strip():
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Question cannot be empty")
        card.question = card_in.question.strip()

    if card_in.answer is not None:
        if not card_in.answer.strip():
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Answer cannot be empty")
        card.answer = card_in.answer.strip()

    if card_in.category is not None:
        card.category = card_in.category.strip()

    if card_in.is_favorite is not None:
        card.is_favorite = card_in.is_favorite

    if card_in.mastery_percentage is not None:
        card.mastery_percentage = card_in.mastery_percentage

    db.commit()
    db.refresh(card)
    return card

@router.delete("/{card_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_flashcard(card_id: int, db: Session = Depends(get_db)):
    """Delete flashcard by ID."""
    card = db.query(Flashcard).filter(Flashcard.id == card_id).first()
    if not card:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Flashcard not found")
    db.delete(card)
    db.commit()
    return None

@router.patch("/{card_id}/favorite", response_model=FlashcardResponse)
def toggle_favorite(card_id: int, db: Session = Depends(get_db)):
    """Toggle the favorite status of a flashcard."""
    card = db.query(Flashcard).filter(Flashcard.id == card_id).first()
    if not card:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Flashcard not found")
    card.is_favorite = not card.is_favorite
    db.commit()
    db.refresh(card)
    return card

@router.post("/{card_id}/grade", response_model=FlashcardResponse)
def grade_flashcard(card_id: int, grade_req: FlashcardGradeRequest, db: Session = Depends(get_db)):
    """
    Spaced repetition grading calculation:
    - Again: resets/lowers interval to '<1m', decreases mastery by 15%
    - Hard: interval '6m', increases mastery by 5%
    - Good: interval '1d', increases mastery by 15%
    - Easy: interval '4d', sets or increases mastery by 25%
    """
    card = db.query(Flashcard).filter(Flashcard.id == card_id).first()
    if not card:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Flashcard not found")

    grade = grade_req.grade.lower().strip()
    if grade == "again":
        card.difficulty_interval = "<1m"
        card.mastery_percentage = max(0, card.mastery_percentage - 15)
    elif grade == "hard":
        card.difficulty_interval = "6m"
        card.mastery_percentage = min(100, max(10, card.mastery_percentage + 5))
    elif grade == "good":
        card.difficulty_interval = "1d"
        card.mastery_percentage = min(100, card.mastery_percentage + 15)
    elif grade == "easy":
        card.difficulty_interval = "4d"
        card.mastery_percentage = min(100, max(80, card.mastery_percentage + 25))
    else:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Invalid grade '{grade}'. Must be Again, Hard, Good, or Easy.")

    card.last_studied_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(card)
    return card
