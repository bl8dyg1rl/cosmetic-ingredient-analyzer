import csv
from pathlib import Path

from sqlalchemy.orm import Session

from backend.app.models.ingredient import Ingredient
from backend.app.models.ingredient_function import IngredientFunction
from backend.app.models.ingredient_skin_type import IngredientSkinType
from backend.app.models.ingredient_precaution import IngredientPrecaution


def get_ingredient_map(db: Session):
    ingredients = db.query(Ingredient).all()

    return {
        ingredient.inci_name: ingredient.id
        for ingredient in ingredients
    }


def import_functions(
    db: Session,
    csv_path: str,
) -> int:

    ingredient_map = get_ingredient_map(db)

    imported = 0

    with Path(csv_path).open(
        mode="r",
        encoding="utf-8",
        newline="",
    ) as file:

        reader = csv.DictReader(file)

        for row in reader:

            inci_name = row["ingredient_inci"].strip()
            function = row["function"].strip()

            ingredient_id = ingredient_map.get(inci_name)

            if ingredient_id is None:
                print(
                    f"Ingredient not found: {inci_name}"
                )
                continue

            existing = (
                db.query(IngredientFunction)
                .filter(
                    IngredientFunction.ingredient_id == ingredient_id,
                    IngredientFunction.function == function,
                )
                .first()
            )

            if existing:
                continue

            db.add(
                IngredientFunction(
                    ingredient_id=ingredient_id,
                    function=function,
                )
            )

            imported += 1

    db.commit()

    return imported


def import_skin_types(
    db: Session,
    csv_path: str,
) -> int:

    ingredient_map = get_ingredient_map(db)

    imported = 0

    with Path(csv_path).open(
        mode="r",
        encoding="utf-8",
        newline="",
    ) as file:

        reader = csv.DictReader(file)

        for row in reader:

            inci_name = row["ingredient_inci"].strip()
            skin_type = row["skin_type"].strip()

            ingredient_id = ingredient_map.get(inci_name)

            if ingredient_id is None:
                print(
                    f"Ingredient not found: {inci_name}"
                )
                continue

            existing = (
                db.query(IngredientSkinType)
                .filter(
                    IngredientSkinType.ingredient_id == ingredient_id,
                    IngredientSkinType.skin_type == skin_type,
                )
                .first()
            )

            if existing:
                continue

            db.add(
                IngredientSkinType(
                    ingredient_id=ingredient_id,
                    skin_type=skin_type,
                )
            )

            imported += 1

    db.commit()

    return imported


def import_precautions(
    db: Session,
    csv_path: str,
) -> int:

    ingredient_map = get_ingredient_map(db)

    imported = 0

    with Path(csv_path).open(
        mode="r",
        encoding="utf-8",
        newline="",
    ) as file:

        reader = csv.DictReader(file)

        for row in reader:

            inci_name = row["ingredient_inci"].strip()
            precaution_type = row["precaution_type"].strip()
            description = row["description"].strip()

            ingredient_id = ingredient_map.get(inci_name)

            if ingredient_id is None:
                print(
                    f"Ingredient not found: {inci_name}"
                )
                continue

            existing = (
                db.query(IngredientPrecaution)
                .filter(
                    IngredientPrecaution.ingredient_id == ingredient_id,
                    IngredientPrecaution.precaution_type == precaution_type,
                    IngredientPrecaution.description == description,
                )
                .first()
            )

            if existing:
                continue

            db.add(
                IngredientPrecaution(
                    ingredient_id=ingredient_id,
                    precaution_type=precaution_type,
                    description=description,
                )
            )

            imported += 1

    db.commit()

    return imported
