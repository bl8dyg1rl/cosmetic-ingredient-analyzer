import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from backend.app.db.database import SessionLocal

from backend.app.services.import_ingredients import import_ingredients
from backend.app.services.import_relationships import (
    import_functions,
    import_skin_types,
    import_precautions,
)
from backend.app.services.import_aliases import import_aliases


DATA_DIR = PROJECT_ROOT / "data"
INGREDIENTS_CSV = DATA_DIR / "ingredients.csv"
FUNCTIONS_CSV = DATA_DIR / "ingredient_functions.csv"
SKIN_TYPES_CSV = DATA_DIR / "ingredient_skin_types.csv"
PRECAUTIONS_CSV = DATA_DIR / "ingredient_precautions.csv"
ALIASES_CSV = DATA_DIR / "ingredient_aliases.csv"


def main():

    db = SessionLocal()

    try:

        ingredients = import_ingredients(
            db=db,
            csv_path=INGREDIENTS_CSV,
        )

        functions = import_functions(
            db=db,
            csv_path=FUNCTIONS_CSV,
        )

        skin_types = import_skin_types(
            db=db,
            csv_path=SKIN_TYPES_CSV,
        )

        precautions = import_precautions(
            db=db,
            csv_path=PRECAUTIONS_CSV,
        )

        aliases = import_aliases(
            db=db,
            csv_path=ALIASES_CSV,
        )

        print(
            f"Ingredients imported: {ingredients}"
        )

        print(
            f"Functions imported: {functions}"
        )

        print(
            f"Skin types imported: {skin_types}"
        )

        print(
            f"Precautions imported: {precautions}"
        )

        print(
            f"Aliases imported: {aliases}"
        )

    finally:
        db.close()


if __name__ == "__main__":
    main()
