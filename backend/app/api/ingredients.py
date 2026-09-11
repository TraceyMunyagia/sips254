from fastapi import APIRouter, HTTPException
from app.models.bartender_models import IngredientRequest, BartenderResponse, SuggestedCocktail
from app.rag.retrieval import find_matching_cocktails
from app.rag.gemini_client import rank_and_explain

router = APIRouter(prefix="/bartender", tags=["bartender"])


@router.post("/ingredients", response_model=BartenderResponse)
async def suggest_from_ingredients(request: IngredientRequest):
    candidates = find_matching_cocktails(request.ingredients, request.spirits)

    if not candidates:
        return BartenderResponse(
            suggestions=[],
            shopping_suggestions=["Try adding a base spirit like vodka, gin, or Kenya Cane to get started."],
        )

    try:
        ranked = rank_and_explain(candidates, request.preferences.model_dump() if request.preferences else None)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI ranking failed: {e}")

    suggestions = [SuggestedCocktail(**item) for item in ranked]

    return BartenderResponse(suggestions=suggestions)