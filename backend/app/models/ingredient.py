from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from backend.app.db.database import Base


class Ingredient(Base):
    __tablename__ = "ingredients"

    id: Mapped[int] = mapped_column(
        primary_key=True
    )

    inci_name: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
    )

    common_name: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True,
    )

    description: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    category: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
    )

    evidence_level: Mapped[str | None] = mapped_column(
        String(50),
        nullable=True,
    )

    notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    functions = relationship(
        "IngredientFunction",
        back_populates="ingredient",
        cascade="all, delete-orphan",
    )

    skin_types = relationship(
        "IngredientSkinType",
        back_populates="ingredient",
        cascade="all, delete-orphan",
    )

    precautions = relationship(
        "IngredientPrecaution",
        back_populates="ingredient",
        cascade="all, delete-orphan",
    )

    aliases = relationship(
        "IngredientAlias",
        back_populates="ingredient",
        cascade="all, delete-orphan",
    )
