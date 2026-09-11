from pydantic import BaseModel
from typing import Optional


class Preferences(BaseModel):
    strength: Optional[str] = None      # "mild" | "medium" | "strong"
    sweetness: Optional[str] = None     # "dry" | "medium" | "sweet"
    fizzy: Optional[bool] = None
    tropical: Optional[bool] = None


class IngredientRequest(BaseModel):
    ingredients: list[str]
    spirits: list[str] = []
    preferences: Optional[Preferences] = None


class SpiritOnlyRequest(BaseModel):
    spirit: str
    preferences: Optional[Preferences] = None


class PunchRequest(BaseModel):
    people: int
    available_spirits: list[str]
    available_mixers: list[str] = []
    strength: Optional[str] = None
    sweetness: Optional[str] = None


class SuggestedCocktail(BaseModel):
    cocktail_id: Optional[str] = None
    name: str
    match_score: float
    have_ingredients: list[str]
    missing_ingredients: list[str]
    explanation: str
    instructions: Optional[str] = None


class BartenderResponse(BaseModel):
    suggestions: list[SuggestedCocktail]
    shopping_suggestions: list[str] = []