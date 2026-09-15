import csv
from pathlib import Path

from sqlalchemy.orm import Session

from backend.app.models.ingredient import Ingredient
from backend.app.models.ingredient_alias import IngredientAlias


def import_aliases(
    db: Session,
    csv_path: str,
) -> int:

    path = Path(csv_path)

    if not path.exists():
        raise FileNotFoundError(
            f"CSV file not found: {csv_path}"
        )

    ingredients = db.query(Ingredient).all()

    ingredient_map = {
        ingredient.inci_name: ingredient.id
        for ingredient in ingredients
    }

    imported = 0

    with path.open(
        mode="r",
        encoding="utf-8",
        newline="",
    ) as file:

        reader = csv.DictReader(file)

        for row in reader:

            inci_name = row["ingredient_inci"].strip()
            alias = row["alias"].strip()

            ingredient_id = ingredient_map.get(
                inci_name
            )

            if ingredient_id is None:
                print(
                    f"Ingredient not found: {inci_name}"
                )
                continue

            existing = (
                db.query(IngredientAlias)
                .filter(
                    IngredientAlias.alias.ilike(alias)
                )
                .first()
            )

            if existing:
                continue

            db.add(
                IngredientAlias(
                    ingredient_id=ingredient_id,
                    alias=alias,
                )
            )

            imported += 1

    db.commit()

    return imported
