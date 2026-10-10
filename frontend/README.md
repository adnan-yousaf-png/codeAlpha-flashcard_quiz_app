# FlashLearn – Flashcard Quiz App

A full-stack flashcard and quiz app built with **Flutter** and **FastAPI**. The UI is designed in **Google Stitch** and implemented to match the design.

## Features
- Study mode with 3D card flip and Show/Hide Answer
- Grading buttons (Again, Hard, Good, Easy) and progress tracking
- Add, edit and delete flashcards with input validation
- Search and filter (All, Recent, Favorites, Mastered)
- Multiple-choice quiz mode with score and review screen
- Decks, daily streak and mastery stats
- Loading, empty and error states on every screen

## Tech Stack
| Layer | Technology |
|-------|------------|
| Frontend | Flutter, Dart, Provider, http, google_fonts |
| Backend | FastAPI, SQLAlchemy, Pydantic, Uvicorn |
| Database | SQLite |
| Design | Google Stitch |

## Screenshots
| Study | All Cards | Add/Edit | Quiz | Result |
|-------|-----------|----------|------|--------|
| ([Quiz](image.png)/quiz.png) | ![](![all cards](image-1.png)/cards.png) | ![](/![Deck details](image-2.png).png) | ![](![Delete card](image-3.png)/quiz.png) | ![](![show result](image-4.png)/result.png) |

## Project Structure
```
flashcard_quiz_app/
├── backend/    # FastAPI + SQLite (app/, routers/, models, schemas)
└── frontend/   # Flutter app (lib/: config, theme, models, services, providers, widgets, screens)
```

## Getting Started

### Prerequisites
- Python 3.10+
- Flutter SDK
- Android emulator (or Chrome/Windows desktop)

### 1. Run the backend
```
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
python seed_data.py
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
API docs (Swagger): http://127.0.0.1:8000/docs

### 2. Run the frontend
```
cd frontend
flutter pub get
flutter run -d emulator-5554
```
Android emulator uses `http://10.0.2.2:8000` to reach the backend (set in `lib/config/api_config.dart`).

## API Overview
- `/decks` – deck CRUD and stats
- `/flashcards` – search, filter, CRUD, grading
- `/quiz` – generate questions and evaluate answers

## Testing
```
cd backend && python test_backend.py
cd frontend && flutter analyze && flutter test
```

## Future Improvements
- User login (JWT)
- Offline mode
- Quiz history and progress charts

## Author
**Adnan Yousaf** – BS Software Engineering, PMAS Arid Agriculture University Rawalpindi
GitHub: adnan-yousaf-png