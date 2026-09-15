import csv
from pathlib import Path

from sqlalchemy.orm import Session

from backend.app.models.ingredient import Ingredient


def import_ingredients(
    db: Session,
    csv_path: str,
) -> int:

    path = Path(csv_path)

    if not path.exists():
        raise FileNotFoundError(
            f"CSV file not found: {csv_path}"
        )

    imported = 0

    with path.open(
        mode="r",
        encoding="utf-8",
        newline="",
    ) as file:

        reader = csv.DictReader(file)

        for row in reader:

            inci_name = row["inci_name"].strip()

            existing = (
                db.query(Ingredient)
                .filter(
                    Ingredient.inci_name == inci_name
                )
                .first()
            )

            if existing:
                continue

            ingredient = Ingredient(
                inci_name=inci_name,
                common_name=row["common_name"] or None,
                description=row["description"] or None,
                category=row["category"] or None,
                evidence_level=row["evidence_level"] or None,
                notes=row["notes"] or None,
            )

            db.add(ingredient)
            imported += 1

    db.commit()

    return imported
