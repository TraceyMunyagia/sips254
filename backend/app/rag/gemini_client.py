import os
import json
from google import genai

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

MODEL_NAME = "gemini-3.6-flash"  # GA as of July 2026 — check ai.google.dev/gemini-api/docs/latest-model if this changes again

SYSTEM_INSTRUCTION = """You are the Sips254 AI Bartender. You ONLY rank and explain
cocktails from the candidate list you are given — you never invent a cocktail that
isn't in the candidate list. You respond with strict JSON matching the requested
schema, and nothing else (no markdown fences, no commentary outside the JSON)."""


def rank_and_explain(candidates: list[dict], preferences: dict | None) -> list[dict]:
    """Send the retrieved candidates to Gemini for natural-language ranking/explanation.
    Gemini reorders and writes explanations; it does not add new cocktails."""

    if not candidates:
        return []

    candidate_summary = [
        {
            "name": c["name"],
            "id": c["id"],
            "match_score": c["match"]["score"],
            "have": c["match"]["have"],
            "missing": c["match"]["missing"],
            "strength": c["strength"],
            "sweetness": c["sweetness"],
            "fizz": c["fizz"],
            "is_kenyan_inspired": c["is_kenyan_inspired"],
        }
        for c in candidates
    ]

    prompt = f"""
Candidate cocktails (JSON): {json.dumps(candidate_summary)}

User preferences (JSON, may be empty): {json.dumps(preferences or {})}

Task: Rank these candidates best-to-worst for this user, considering their stated
preferences (strength, sweetness, fizzy, tropical) alongside the match_score already
computed. Write a short (1-2 sentence) explanation per cocktail: mention what they
have, what they're missing (if anything), and why it fits their preferences.

Respond with ONLY a JSON array in this exact shape, no other text:
[
  {{
    "cocktail_id": "<id>",
    "name": "<name>",
    "match_score": <float 0-1>,
    "have_ingredients": [<strings>],
    "missing_ingredients": [<strings>],
    "explanation": "<string>"
  }}
]
"""

    interaction = client.interactions.create(
        model=MODEL_NAME,
        input=prompt,
        system_instruction=SYSTEM_INSTRUCTION,
    )

    text = interaction.output_text.strip()

    # Defensive cleanup in case the model wraps output in markdown fences anyway
    if text.startswith("```"):
        text = text.strip("`")
        if text.startswith("json"):
            text = text[4:]
        text = text.strip()

    return json.loads(text)

def explain_punch_recommendation(candidates: list[dict], people: int, strength: str | None, sweetness: str | None) -> list[dict]:
    """Same pattern as rank_and_explain, but tailored to punch/party framing —
    explanations mention batch-friendliness and crowd-pleasing qualities."""

    if not candidates:
        return []

    candidate_summary = [
        {
            "name": c["name"],
            "id": c["id"],
            "match_score": c["match"]["score"],
            "have": c["match"]["have"],
            "missing": c["match"]["missing"],
            "base_servings": c["servings"],
            "strength": c["strength"],
            "sweetness": c["sweetness"],
        }
        for c in candidates
    ]

    prompt = f"""
Candidate cocktails suited for batching (JSON): {json.dumps(candidate_summary)}

Party size: {people} people
Desired strength: {strength or "no preference"}
Desired sweetness: {sweetness or "no preference"}

Task: Rank these candidates for a party punch, considering how crowd-pleasing and
easy-to-batch each is, alongside the match_score and stated preferences. Write a
short (1-2 sentence) explanation per cocktail focused on why it works for a group
of {people}.

Respond with ONLY a JSON array in this exact shape, no other text:
[
  {{
    "cocktail_id": "<id>",
    "name": "<name>",
    "match_score": <float 0-1>,
    "have_ingredients": [<strings>],
    "missing_ingredients": [<strings>],
    "explanation": "<string>"
  }}
]
"""

    interaction = client.interactions.create(
        model=MODEL_NAME,
        input=prompt,
        system_instruction=SYSTEM_INSTRUCTION,
    )

    text = interaction.output_text.strip()
    if text.startswith("```"):
        text = text.strip("`")
        if text.startswith("json"):
            text = text[4:]
        text = text.strip()

    return json.loads(text)