import random
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Deck, Flashcard, QuizAttempt
from ..schemas import QuizQuestionResponse, QuizSubmissionRequest, QuizResultResponse, QuizResultCard

router = APIRouter(prefix="/api/quiz", tags=["Quiz"])

@router.get("", response_model=List[QuizQuestionResponse])
def generate_quiz(
    deck_id: Optional[int] = Query(None, description="Deck ID for quiz questions"),
    count: int = Query(10, ge=1, le=50, description="Number of questions"),
    db: Session = Depends(get_db)
):
    """Generate dynamic multiple-choice quiz questions with randomized distractor options."""
    query = db.query(Flashcard)
    if deck_id is not None:
        query = query.filter(Flashcard.deck_id == deck_id)
    
    all_cards = query.all()
    if len(all_cards) < 2:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Need at least 2 flashcards in deck to generate a quiz."
        )

    # Pick up to count questions
    selected_cards = random.sample(all_cards, min(count, len(all_cards)))
    all_answers = [c.answer for c in all_cards]

    quiz_questions = []
    for card in selected_cards:
        # Collect distractors from other cards
        distractors = [ans for ans in all_answers if ans != card.answer]
        # Pick up to 3 distractors
        num_distractors = min(3, len(distractors))
        chosen_distractors = random.sample(distractors, num_distractors) if distractors else []
        
        # In case we have fewer than 3 distractors, add synthetic ones
        default_distractors = [
            "A build pipeline optimization technique for native bytecode.",
            "An asynchronous task scheduler managed by Dart event loop.",
            "A compile-time static type analyzer rule set."
        ]
        while len(chosen_distractors) < 3:
            candidate = random.choice(default_distractors)
            if candidate not in chosen_distractors and candidate != card.answer:
                chosen_distractors.append(candidate)

        options = [card.answer] + chosen_distractors[:3]
        random.shuffle(options)

        quiz_questions.append(
            QuizQuestionResponse(
                id=card.id,
                question=card.question,
                category=card.category,
                options=options
            )
        )

    return quiz_questions

@router.post("/submit", response_model=QuizResultResponse)
def submit_quiz(submission: QuizSubmissionRequest, db: Session = Depends(get_db)):
    """Evaluate quiz submission, compute score, and record history."""
    if not submission.answers:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No answers submitted")

    total = len(submission.answers)
    correct_count = 0
    results = []

    for ans in submission.answers:
        card = db.query(Flashcard).filter(Flashcard.id == ans.card_id).first()
        if not card:
            continue
        
        is_correct = (ans.selected_option.strip() == card.answer.strip())
        if is_correct:
            correct_count += 1
            # Boost mastery slightly on correct quiz answer
            card.mastery_percentage = min(100, card.mastery_percentage + 10)
        else:
            # Drop mastery slightly on wrong answer
            card.mastery_percentage = max(0, card.mastery_percentage - 10)

        results.append(
            QuizResultCard(
                card_id=card.id,
                question=card.question,
                selected_option=ans.selected_option,
                correct_answer=card.answer,
                is_correct=is_correct
            )
        )

    score_pct = round((correct_count / total) * 100, 1) if total > 0 else 0.0

    # Record attempt
    attempt = QuizAttempt(
        deck_id=submission.deck_id,
        total_questions=total,
        correct_answers=correct_count,
        score_percentage=score_pct
    )
    db.add(attempt)
    db.commit()

    return QuizResultResponse(
        total_questions=total,
        correct_answers=correct_count,
        score_percentage=score_pct,
        results=results
    )
