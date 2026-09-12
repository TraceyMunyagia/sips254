from app.rag.retrieval import get_all_cocktails_with_ingredients, normalize


def find_punch_candidates(available_spirits: list[str], available_mixers: list[str], top_n: int = 6) -> list[dict]:
    """Find cocktails suited to batch/punch format — favors drinks already
    marked with higher servings, but falls back to any drink whose required
    ingredients are covered by what's on hand, since most recipes can be
    scaled into a punch even if not authored as one."""

    available = {normalize(i) for i in available_spirits + available_mixers}
    all_cocktails = get_all_cocktails_with_ingredients()

    scored = []
    for cocktail in all_cocktails:
        required_names = {
            normalize(i["name"]) for i in cocktail["required_ingredients"] if not i["is_optional"]
        }
        if not required_names:
            continue

        have = required_names & available
        score = len(have) / len(required_names)

        if score > 0:
            scored.append({
                **cocktail,
                "match": {
                    "score": round(score, 2),
                    "have": sorted(have),
                    "missing": sorted(required_names - available),
                },
            })

    # Favor cocktails already authored with servings > 1 (punch-style), then by match score
    scored.sort(key=lambda c: (c["servings"] > 1, c["match"]["score"]), reverse=True)
    return scored[:top_n]


def scale_recipe(cocktail: dict, target_people: int) -> dict:
    """Scale a cocktail's ingredient amounts from its authored servings to
    a target headcount, assuming each person gets one authored serving."""
    base_servings = cocktail.get("servings", 1) or 1
    multiplier = target_people / base_servings

    scaled_ingredients = []
    for ingredient in cocktail["required_ingredients"]:
        scaled_ingredients.append({
            "name": ingredient["name"],
            "original_amount": ingredient["amount"],
            "scaled_amount": round(ingredient["amount"] * multiplier, 1),
            "unit": ingredient["unit"],
        })

    return {
        "cocktail_name": cocktail["name"],
        "target_people": target_people,
        "base_servings": base_servings,
        "multiplier": round(multiplier, 2),
        "scaled_ingredients": scaled_ingredients,
        "instructions": cocktail["instructions"],
        "garnish": cocktail.get("garnish"),
    }