from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from backend.app.db.database import Base


class IngredientFunction(Base):
    __tablename__ = "ingredient_functions"

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

    function: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    ingredient = relationship(
        "Ingredient",
        back_populates="functions",
    )
