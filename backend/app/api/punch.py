from fastapi import APIRouter, HTTPException
from app.models.bartender_models import PunchRequest, PunchResponse, PunchRecommendation, ScaledRecipe
from app.rag.punch_retrieval import find_punch_candidates, scale_recipe
from app.rag.gemini_client import explain_punch_recommendation

router = APIRouter(prefix="/bartender", tags=["bartender"])


@router.post("/punch", response_model=PunchResponse)
async def suggest_punch(request: PunchRequest):
    candidates = find_punch_candidates(request.available_spirits, request.available_mixers)

    if not candidates:
        raise HTTPException(
            status_code=404,
            detail="No punch-friendly cocktails found for the ingredients provided.",
        )

    try:
        ranked = explain_punch_recommendation(
            candidates, request.people, request.strength, request.sweetness
        )
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI ranking failed: {e}")

    candidates_by_id = {c["id"]: c for c in candidates}

    recommendations = []
    for item in ranked:
        cocktail = candidates_by_id.get(item["cocktail_id"])
        if not cocktail:
            continue

        scaled = scale_recipe(cocktail, request.people)

        recommendations.append(PunchRecommendation(
            cocktail_id=item["cocktail_id"],
            name=item["name"],
            match_score=item["match_score"],
            explanation=item["explanation"],
            scaled_recipe=ScaledRecipe(**scaled),
        ))

    return PunchResponse(recommendations=recommendations)