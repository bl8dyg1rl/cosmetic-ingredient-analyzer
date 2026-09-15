from pydantic import BaseModel, ConfigDict


class IngredientCreate(BaseModel):
    inci_name: str
    common_name: str | None = None
    description: str | None = None
    category: str | None = None
    evidence_level: str | None = None
    notes: str | None = None


class IngredientResponse(IngredientCreate):
    id: int

    model_config = ConfigDict(from_attributes=True)


class IngredientDetailResponse(IngredientResponse):
    functions: list[str]
    skin_types: list[str]
    precautions: list[str]