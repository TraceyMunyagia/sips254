import json
import os
from pathlib import Path
from supabase import create_client

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_SERVICE_ROLE_KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]

client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

SEED_FILE = Path(__file__).parent.parent.parent / "database" / "seed" / "recipes.json"


def get_id_by_name(table: str, name: str):
    if name is None:
        return None
    result = client.table(table).select("id").eq("name", name).execute()
    if result.data:
        return result.data[0]["id"]
    raise ValueError(f"'{name}' not found in {table} — add it to reference data first")


def cocktail_exists(name: str) -> bool:
    result = client.table("cocktails").select("id").eq("name", name).execute()
    return bool(result.data)


def seed():
    recipes = json.loads(SEED_FILE.read_text())
    inserted, skipped = 0, 0

    for recipe in recipes:
        if cocktail_exists(recipe["name"]):
            print(f"Skipping (already exists): {recipe['name']}")
            skipped += 1
            continue

        category_id = get_id_by_name("categories", recipe["category"])
        glassware_id = get_id_by_name("glassware", recipe["glassware"])
        prep_id = get_id_by_name("preparation_methods", recipe["preparation_method"])
        spirit_id = get_id_by_name("spirits", recipe.get("primary_spirit"))

        cocktail = client.table("cocktails").insert({
            "name": recipe["name"],
            "description": recipe.get("description"),
            "category_id": category_id,
            "glassware_id": glassware_id,
            "preparation_method_id": prep_id,
            "primary_spirit_id": spirit_id,
            "strength": recipe["strength"],
            "sweetness": recipe["sweetness"],
            "sourness": recipe["sourness"],
            "bitterness": recipe["bitterness"],
            "fruitiness": recipe["fruitiness"],
            "fizz": recipe["fizz"],
            "difficulty": recipe["difficulty"],
            "servings": recipe["servings"],
            "garnish": recipe.get("garnish"),
            "instructions": recipe["instructions"],
            "is_kenyan_inspired": recipe["is_kenyan_inspired"],
            "status": "published",
        }).execute()

        cocktail_id = cocktail.data[0]["id"]

        for item in recipe["ingredients"]:
            row = {
                "cocktail_id": cocktail_id,
                "amount": item["amount"],
                "unit": item["unit"],
                "is_optional": item.get("is_optional", False),
            }
            if "spirit" in item:
                row["spirit_id"] = get_id_by_name("spirits", item["spirit"])
            else:
                row["ingredient_id"] = get_id_by_name("ingredients", item["ingredient"])

            client.table("cocktail_ingredients").insert(row).execute()

        print(f"Inserted: {recipe['name']}")
        inserted += 1

    print(f"\nDone. Inserted {inserted}, skipped {skipped} (already existed).")


if __name__ == "__main__":
    seed()