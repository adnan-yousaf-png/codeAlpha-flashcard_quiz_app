import json
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def run_tests():
    print("--- 1. Testing Root Endpoint ---")
    res = client.get("/")
    assert res.status_code == 200, f"Root failed: {res.text}"
    print("[OK] Root OK:", res.json())

    print("\n--- 2. Testing Decks Endpoint ---")
    res = client.get("/api/decks")
    assert res.status_code == 200, f"Get decks failed: {res.text}"
    decks = res.json()
    assert len(decks) > 0, "No decks found"
    print(f"[OK] Decks OK: Found {len(decks)} deck(s), Deck 1 card count: {decks[0]['card_count']}")

    print("\n--- 3. Testing Deck Stats ---")
    deck_id = decks[0]["id"]
    res = client.get(f"/api/decks/{deck_id}/stats")
    assert res.status_code == 200, f"Deck stats failed: {res.text}"
    print("[OK] Stats OK:", res.json())

    print("\n--- 4. Testing Flashcards List & Filters ---")
    res = client.get(f"/api/flashcards?deck_id={deck_id}")
    assert res.status_code == 200, f"Get flashcards failed: {res.text}"
    cards = res.json()
    assert len(cards) >= 12, f"Expected 12 cards, got {len(cards)}"
    print(f"[OK] Flashcards OK: Retrieved {len(cards)} cards")

    # Filter favorites
    res_fav = client.get(f"/api/flashcards?deck_id={deck_id}&filter_type=favorites")
    assert res_fav.status_code == 200
    fav_cards = res_fav.json()
    print(f"[OK] Favorites Filter OK: Retrieved {len(fav_cards)} favorite cards")

    # Search filter
    res_search = client.get(f"/api/flashcards?search=Reload")
    assert res_search.status_code == 200
    search_cards = res_search.json()
    assert len(search_cards) > 0
    print(f"[OK] Search OK: Found {len(search_cards)} card(s) matching 'Reload'")

    print("\n--- 5. Testing Validation (Empty Question should fail) ---")
    bad_res = client.post("/api/flashcards", json={"deck_id": deck_id, "question": "   ", "answer": "Valid answer"})
    assert bad_res.status_code == 422, f"Expected 422 for empty question, got {bad_res.status_code}"
    print("[OK] Validation OK: Correctly rejected empty question prompt with 422")

    print("\n--- 6. Testing Spaced Repetition Grading ---")
    card_id = cards[0]["id"]
    res_grade = client.post(f"/api/flashcards/{card_id}/grade", json={"grade": "Easy"})
    assert res_grade.status_code == 200
    print(f"[OK] Grading OK: Card mastery updated to {res_grade.json()['mastery_percentage']}%")

    print("\n--- 7. Testing Quiz Generation ---")
    res_quiz = client.get(f"/api/quiz?deck_id={deck_id}&count=4")
    assert res_quiz.status_code == 200
    quiz_qs = res_quiz.json()
    assert len(quiz_qs) == 4
    for q in quiz_qs:
        assert len(q["options"]) == 4, f"Question options count expected 4, got {len(q['options'])}"
    print(f"[OK] Quiz Generation OK: Generated 4 questions each with 4 randomized options")

    print("\n--- 8. Testing Quiz Submission ---")
    submission_payload = {
        "deck_id": deck_id,
        "answers": [
            {"card_id": quiz_qs[0]["id"], "selected_option": quiz_qs[0]["options"][0]},
            {"card_id": quiz_qs[1]["id"], "selected_option": "Wrong Option"}
        ]
    }
    res_sub = client.post("/api/quiz/submit", json=submission_payload)
    assert res_sub.status_code == 200
    result_data = res_sub.json()
    print("[OK] Quiz Submission OK: Result:", result_data)

    print("\nALL BACKEND TESTS PASSED SUCCESSFULLY!")

if __name__ == "__main__":
    run_tests()
