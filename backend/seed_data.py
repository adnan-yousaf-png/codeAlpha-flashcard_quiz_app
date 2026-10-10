import os
from datetime import datetime, timedelta
from app.database import SessionLocal, Base, engine
from app.models import Deck, Flashcard

def seed():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    # Check if deck already exists
    existing_deck = db.query(Deck).first()
    if existing_deck:
        print("Database already contains data. Skipping seed.")
        db.close()
        return

    # Create Primary Deck
    deck = Deck(
        name="Mobile Core Dev",
        description="Core concepts for Flutter and mobile application architecture.",
        category="Mobile Core Dev"
    )
    db.add(deck)
    db.commit()
    db.refresh(deck)

    # 12 Flashcards matching Stitch UI
    cards_data = [
        {
            "question": "What is the difference between Hot Reload and Hot Restart in Flutter?",
            "answer": "Hot Reload preserves application state while injecting updated code into the Dart VM. Hot Restart completely resets state, clears application memory, and recompiles code from entry point.",
            "category": "Architecture",
            "is_favorite": True,
            "mastery_percentage": 75,
            "difficulty_interval": "1d",
            "last_studied_at": datetime.utcnow() - timedelta(hours=2)
        },
        {
            "question": "What is a StatefulWidget?",
            "answer": "A widget that has mutable state that can change dynamically during its lifetime, rebuilding its interface via setState.",
            "category": "Flutter UI",
            "is_favorite": True,
            "mastery_percentage": 85,
            "difficulty_interval": "4d",
            "last_studied_at": datetime.utcnow() - timedelta(days=1)
        },
        {
            "question": "What is the BuildContext?",
            "answer": "A handle to the location of a widget in the widget tree, allowing navigation, inherited widget lookups, and theme resolution.",
            "category": "Flutter UI",
            "is_favorite": True,
            "mastery_percentage": 92,
            "difficulty_interval": "4d",
            "last_studied_at": datetime.utcnow() - timedelta(hours=5)
        },
        {
            "question": "Explain Provider vs Riverpod",
            "answer": "Riverpod is a compile-safe rewrite of Provider without BuildContext dependency, catching runtime bugs at compile time.",
            "category": "State Management",
            "is_favorite": False,
            "mastery_percentage": 40,
            "difficulty_interval": "<1m",
            "last_studied_at": datetime.utcnow() - timedelta(hours=12)
        },
        {
            "question": "What is a Flutter Widget hierarchy node?",
            "answer": "A widget is an immutable description of a part of a user interface.",
            "category": "Flutter UI",
            "is_favorite": False,
            "mastery_percentage": 60,
            "difficulty_interval": "6m",
            "last_studied_at": datetime.utcnow() - timedelta(days=2)
        },
        {
            "question": "What is the Flutter StatefulWidget lifecycle order?",
            "answer": "createState() -> initState() -> didChangeDependencies() -> build() -> dispose()",
            "category": "Flutter UI",
            "is_favorite": True,
            "mastery_percentage": 80,
            "difficulty_interval": "4d",
            "last_studied_at": datetime.utcnow() - timedelta(days=3)
        },
        {
            "question": "What is an InheritedWidget in Flutter?",
            "answer": "A base class for widgets that efficiently propagate information down the widget tree without manual parameter passing.",
            "category": "State Management",
            "is_favorite": False,
            "mastery_percentage": 50,
            "difficulty_interval": "1d",
            "last_studied_at": datetime.utcnow() - timedelta(days=4)
        },
        {
            "question": "What is the purpose of Key in Flutter widgets?",
            "answer": "Keys preserve state when widgets move around the widget tree and help the framework differentiate between elements.",
            "category": "Flutter UI",
            "is_favorite": False,
            "mastery_percentage": 70,
            "difficulty_interval": "1d",
            "last_studied_at": datetime.utcnow() - timedelta(days=1)
        },
        {
            "question": "What is the Dart Event Loop and how does it work?",
            "answer": "An execution loop with microtask and event queues processing async operations such as I/O, timers, and isolates sequentially.",
            "category": "Architecture",
            "is_favorite": False,
            "mastery_percentage": 65,
            "difficulty_interval": "6m",
            "last_studied_at": datetime.utcnow() - timedelta(hours=8)
        },
        {
            "question": "What is the difference between final and const in Dart?",
            "answer": "const variables are compile-time constants initialized once, whereas final variables are initialized at runtime upon first access.",
            "category": "Architecture",
            "is_favorite": True,
            "mastery_percentage": 90,
            "difficulty_interval": "4d",
            "last_studied_at": datetime.utcnow() - timedelta(days=5)
        },
        {
            "question": "What is an Isolate in Dart?",
            "answer": "An isolated Dart execution thread with its own private heap memory, communicating strictly through message passing ports.",
            "category": "Architecture",
            "is_favorite": False,
            "mastery_percentage": 35,
            "difficulty_interval": "<1m",
            "last_studied_at": datetime.utcnow() - timedelta(days=6)
        },
        {
            "question": "What is the difference between Future and Stream in Dart?",
            "answer": "A Future represents a single asynchronous value or error available later, whereas a Stream provides a sequence of asynchronous events over time.",
            "category": "State Management",
            "is_favorite": True,
            "mastery_percentage": 88,
            "difficulty_interval": "4d",
            "last_studied_at": datetime.utcnow() - timedelta(hours=3)
        }
    ]

    for item in cards_data:
        card = Flashcard(
            deck_id=deck.id,
            question=item["question"],
            answer=item["answer"],
            category=item["category"],
            is_favorite=item["is_favorite"],
            mastery_percentage=item["mastery_percentage"],
            difficulty_interval=item["difficulty_interval"],
            last_studied_at=item["last_studied_at"]
        )
        db.add(card)

    db.commit()
    print(f"Successfully seeded deck '{deck.name}' with {len(cards_data)} flashcards!")
    db.close()

if __name__ == "__main__":
    seed()
