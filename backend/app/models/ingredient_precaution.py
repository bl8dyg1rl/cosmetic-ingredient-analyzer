from sqlalchemy import ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from backend.app.db.database import Base


class IngredientPrecaution(Base):
    __tablename__ = "ingredient_precautions"

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

    precaution_type: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    description: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    ingredient = relationship(
        "Ingredient",
        back_populates="precautions",
    )
