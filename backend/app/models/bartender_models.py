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


class ScaledIngredient(BaseModel):
    name: str
    original_amount: float
    scaled_amount: float
    unit: str


class ScaledRecipe(BaseModel):
    cocktail_name: str
    target_people: int
    base_servings: int
    multiplier: float
    scaled_ingredients: list[ScaledIngredient]
    instructions: str
    garnish: Optional[str] = None


class PunchRecommendation(BaseModel):
    cocktail_id: str
    name: str
    match_score: float
    explanation: str
    scaled_recipe: ScaledRecipe


class PunchResponse(BaseModel):
    recommendations: list[PunchRecommendation]