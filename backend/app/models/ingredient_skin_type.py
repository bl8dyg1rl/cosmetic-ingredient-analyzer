from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from backend.app.db.database import Base


class IngredientSkinType(Base):
    __tablename__ = "ingredient_skin_types"

    id: Mapped[int] = mapped_column(
        primary_key=True
    )

    ingredient_id: Mapped[int] = mapped_column(
        ForeignKey(
            "ingredients.id",
            ondelete="CASCADE"
        ),
        nullable=False,
    )

    skin_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )

    ingredient = relationship(
        "Ingredient",
        back_populates="skin_types",
    )
