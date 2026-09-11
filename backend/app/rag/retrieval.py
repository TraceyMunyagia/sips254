import os
from supabase import create_client

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_SERVICE_ROLE_KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]

client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


def normalize(name: str) -> str:
    return name.strip().lower()


def get_all_cocktails_with_ingredients() -> list[dict]:
    """Fetch every published cocktail with its resolved ingredient/spirit names."""
    cocktails = client.table("cocktails").select("*").eq("status", "published").execute().data

    result = []
    for cocktail in cocktails:
        rows = client.table("cocktail_ingredients").select(
            "amount, unit, is_optional, ingredients(name), spirits(name)"
        ).eq("cocktail_id", cocktail["id"]).execute().data

        required = []
        for row in rows:
            name = None
            if row.get("ingredients"):
                name = row["ingredients"]["name"]
            elif row.get("spirits"):
                name = row["spirits"]["name"]
            if name:
                required.append({
                    "name": name,
                    "amount": row["amount"],
                    "unit": row["unit"],
                    "is_optional": row["is_optional"],
                })

        result.append({**cocktail, "required_ingredients": required})

    return result


def score_cocktail_match(cocktail: dict, available: set[str]) -> dict:
    """Score how well a cocktail matches the ingredients/spirits on hand."""
    required_names = {normalize(i["name"]) for i in cocktail["required_ingredients"] if not i["is_optional"]}

    if not required_names:
        return {"score": 0.0, "have": [], "missing": []}

    have = required_names & available
    missing = required_names - available

    score = len(have) / len(required_names)

    return {
        "score": round(score, 2),
        "have": sorted(have),
        "missing": sorted(missing),
    }


def find_matching_cocktails(ingredients: list[str], spirits: list[str], top_n: int = 8) -> list[dict]:
    """Retrieve and rank cocktails by ingredient/spirit overlap — this is the
    'retrieval' half of RAG. Gemini only ranks/explains what's retrieved here,
    it never invents cocktails outside this candidate set."""
    available = {normalize(i) for i in ingredients + spirits}
    all_cocktails = get_all_cocktails_with_ingredients()

    scored = []
    for cocktail in all_cocktails:
        match = score_cocktail_match(cocktail, available)
        if match["score"] > 0:
            scored.append({**cocktail, "match": match})

    scored.sort(key=lambda c: c["match"]["score"], reverse=True)
    return scored[:top_n]