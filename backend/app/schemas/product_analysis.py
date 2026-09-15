from pydantic import BaseModel


class IngredientAnalysisRequest(BaseModel):
    ingredients: list[str]


class IngredientAnalysisItem(BaseModel):
    input_name: str
    found: bool

    inci_name: str | None = None
    common_name: str | None = None
    description: str | None = None
    category: str | None = None
    evidence_level: str | None = None

    functions: list[str] = []
    skin_types: list[str] = []
    precautions: list[str] = []


class IngredientAnalysisResponse(BaseModel):
    total_ingredients: int
    found_ingredients: int
    not_found_ingredients: int

    ingredients: list[IngredientAnalysisItem]