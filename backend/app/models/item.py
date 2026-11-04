
from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    ForeignKey,
    Index,
    Numeric,
    String,
    UniqueConstraint,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class FoodDetail(Base):
    __tablename__ = "food_details"

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
    )

    item_name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    category_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "categories.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        server_default=text("CURRENT_TIMESTAMP"),
        nullable=False,
    )

    status: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        server_default=text("TRUE"),
    )

    # One item can have multiple subcategory mappings.
    sub_categories: Mapped[list[ItemSubCategoryMapping]] = relationship(
        back_populates="item",
        lazy="selectin",
    )

    __table_args__ = (
        Index(
            "uq_food_details_category_item_name",
            "category_id",
            text("(LOWER(REGEXP_REPLACE(item_name, '\\s+', '', 'g')))"),
            unique=True,
        ),
    )


class ItemSubCategoryMapping(Base):
    __tablename__ = "item_sub_category_mapping"

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
    )

    item_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "food_details.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=False,
    )

    sub_category_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "sub_categories.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=False,
    )

    price: Mapped[Decimal] = mapped_column(
        Numeric(10, 2),
        nullable=False,
    )

    status: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        server_default=text("TRUE"),
    )

    same_as_sub_category: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        server_default=text("FALSE"),
    )

    # Each mapping belongs to one master item.
    item: Mapped[FoodDetail] = relationship(
        back_populates="sub_categories",
    )

    __table_args__ = (
        CheckConstraint(
            "price >= 0",
            name="chk_mapping_price",
        ),
        UniqueConstraint(
            "item_id",
            "sub_category_id",
            name="uq_item_sub_category",
        ),
        Index(
            "idx_mapping_sub_category",
            "sub_category_id",
        ),
    )


class FoodDetailLog(Base):
    __tablename__ = "food_details_log"

    l_sno: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
    )

    fd_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "food_details.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=False,
    )

    sub_category_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "sub_categories.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=False,
    )

    old_price: Mapped[Decimal] = mapped_column(
        Numeric(10, 2),
        nullable=False,
    )

    new_price: Mapped[Decimal] = mapped_column(
        Numeric(10, 2),
        nullable=False,
    )

    fromdate: Mapped[datetime] = mapped_column(
        server_default=text("CURRENT_TIMESTAMP"),
        nullable=False,
    )

    __table_args__ = (
        CheckConstraint(
            "old_price >= 0",
            name="chk_food_log_old_price",
        ),
        CheckConstraint(
            "new_price >= 0",
            name="chk_food_log_new_price",
        ),
        CheckConstraint(
            "old_price <> new_price",
            name="chk_food_log_price_changed",
        ),
        Index(
            "idx_food_log_item_sub_category",
            "fd_id",
            "sub_category_id",
        ),
    )
