from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Deck, Flashcard
from ..schemas import DeckCreate, DeckResponse, DeckStatsResponse

router = APIRouter(prefix="/api/decks", tags=["Decks"])

@router.get("", response_model=List[DeckResponse])
def get_decks(db: Session = Depends(get_db)):
    """Fetch all decks with calculated card and mastery metrics."""
    decks = db.query(Deck).all()
    results = []
    for d in decks:
        card_count = db.query(Flashcard).filter(Flashcard.deck_id == d.id).count()
        mastered_count = db.query(Flashcard).filter(
            Flashcard.deck_id == d.id,
            Flashcard.mastery_percentage >= 80
        ).count()
        results.append(
            DeckResponse(
                id=d.id,
                name=d.name,
                description=d.description,
                category=d.category,
                created_at=d.created_at,
                card_count=card_count,
                mastered_count=mastered_count,
            )
        )
    return results

@router.get("/{deck_id}", response_model=DeckResponse)
def get_deck(deck_id: int, db: Session = Depends(get_db)):
    """Fetch a single deck by ID."""
    deck = db.query(Deck).filter(Deck.id == deck_id).first()
    if not deck:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Deck not found")
    card_count = db.query(Flashcard).filter(Flashcard.deck_id == deck.id).count()
    mastered_count = db.query(Flashcard).filter(
        Flashcard.deck_id == deck.id,
        Flashcard.mastery_percentage >= 80
    ).count()
    return DeckResponse(
        id=deck.id,
        name=deck.name,
        description=deck.description,
        category=deck.category,
        created_at=deck.created_at,
        card_count=card_count,
        mastered_count=mastered_count,
    )

@router.post("", response_model=DeckResponse, status_code=status.HTTP_201_CREATED)
def create_deck(deck_in: DeckCreate, db: Session = Depends(get_db)):
    """Create a new flashcard deck."""
    new_deck = Deck(
        name=deck_in.name,
        description=deck_in.description,
        category=deck_in.category or "Mobile Core Dev"
    )
    db.add(new_deck)
    db.commit()
    db.refresh(new_deck)
    return DeckResponse(
        id=new_deck.id,
        name=new_deck.name,
        description=new_deck.description,
        category=new_deck.category,
        created_at=new_deck.created_at,
        card_count=0,
        mastered_count=0,
    )

@router.get("/{deck_id}/stats", response_model=DeckStatsResponse)
def get_deck_stats(deck_id: int, db: Session = Depends(get_db)):
    """Fetch study statistics for a deck."""
    deck = db.query(Deck).filter(Deck.id == deck_id).first()
    if not deck:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Deck not found")
    
    total = db.query(Flashcard).filter(Flashcard.deck_id == deck_id).count()
    mastered = db.query(Flashcard).filter(
        Flashcard.deck_id == deck_id,
        Flashcard.mastery_percentage >= 80
    ).count()
    needs_review = db.query(Flashcard).filter(
        Flashcard.deck_id == deck_id,
        Flashcard.mastery_percentage < 80
    ).count()

    return DeckStatsResponse(
        total_cards=total,
        mastered_cards=mastered,
        needs_review_cards=needs_review,
        streak_days=4
    )

@router.delete("/{deck_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_deck(deck_id: int, db: Session = Depends(get_db)):
    """Delete a deck and all associated cards."""
    deck = db.query(Deck).filter(Deck.id == deck_id).first()
    if not deck:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Deck not found")
    db.delete(deck)
    db.commit()
    return None
