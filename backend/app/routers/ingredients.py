from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from backend.app.db.dependencies import get_db
from backend.app.models.ingredient import Ingredient
from backend.app.schemas.ingredient import (
    IngredientCreate,
    IngredientResponse,
    IngredientDetailResponse,
)
from backend.app.schemas.product_analysis import (
    IngredientAnalysisRequest,
    IngredientAnalysisResponse,
    IngredientAnalysisItem,
)

from backend.app.models.ingredient_alias import IngredientAlias


router = APIRouter(
    prefix="/ingredients",
    tags=["Ingredients"],
)

@router.post(
    "/analyze",
    response_model=IngredientAnalysisResponse,
)
def analyze_ingredients(
    request: IngredientAnalysisRequest,
    db: Session = Depends(get_db),
):
    results = []

    for input_name in request.ingredients:

        normalized_name = input_name.strip()

        ingredient = (
            db.query(Ingredient)
            .filter(
                Ingredient.inci_name.ilike(
                    normalized_name
                )
            )
            .first()
        )

        if not ingredient:
            alias = (
                db.query(IngredientAlias)
                .filter(
                    IngredientAlias.alias.ilike(
                        normalized_name
                    )
                )
                .first()
            )

            if alias:
                ingredient = alias.ingredient
            else:
                results.append(
                    IngredientAnalysisItem(
                        input_name=normalized_name,
                        found=False,
                    )
                )

                continue

        results.append(
            IngredientAnalysisItem(
                input_name=normalized_name,
                found=True,

                inci_name=ingredient.inci_name,
                common_name=ingredient.common_name,
                description=ingredient.description,
                category=ingredient.category,
                evidence_level=ingredient.evidence_level,

                functions=[
                    item.function
                    for item in ingredient.functions
                ],

                skin_types=[
                    item.skin_type
                    for item in ingredient.skin_types
                ],

                precautions=[
                    item.description
                    for item in ingredient.precautions
                ],
            )
        )

    found = sum(
        1
        for ingredient in results
        if ingredient.found
    )

    return IngredientAnalysisResponse(
        total_ingredients=len(results),
        found_ingredients=found,
        not_found_ingredients=len(results) - found,
        ingredients=results,
    )

@router.post(
    "/",
    response_model=IngredientResponse,
)
def create_ingredient(
    ingredient: IngredientCreate,
    db: Session = Depends(get_db),
):
    existing_ingredient = (
        db.query(Ingredient)
        .filter(
            Ingredient.inci_name == ingredient.inci_name
        )
        .first()
    )

    if existing_ingredient:
        raise HTTPException(
            status_code=409,
            detail="Ingredient already exists",
        )

    new_ingredient = Ingredient(
        **ingredient.model_dump()
    )

    db.add(new_ingredient)
    db.commit()
    db.refresh(new_ingredient)

    return new_ingredient


@router.get(
    "/{inci_name}",
    response_model=IngredientDetailResponse,
)
def get_ingredient(
    inci_name: str,
    db: Session = Depends(get_db),
):
    ingredient = (
        db.query(Ingredient)
        .filter(
            Ingredient.inci_name.ilike(inci_name)
        )
        .first()
    )

    if not ingredient:
        raise HTTPException(
            status_code=404,
            detail="Ingredient not found",
        )

    return {
        "id": ingredient.id,
        "inci_name": ingredient.inci_name,
        "common_name": ingredient.common_name,
        "description": ingredient.description,
        "category": ingredient.category,
        "evidence_level": ingredient.evidence_level,
        "notes": ingredient.notes,

        "functions": [
            item.function
            for item in ingredient.functions
        ],

        "skin_types": [
            item.skin_type
            for item in ingredient.skin_types
        ],

        "precautions": [
            item.description
            for item in ingredient.precautions
        ],
    }

