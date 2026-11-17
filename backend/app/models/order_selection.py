
from datetime import date, datetime

from sqlalchemy import (
    BigInteger,
    Integer,
    Date,
    DateTime,
    Boolean,
    ForeignKey,
    CheckConstraint,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class OrderSelectionAssignment(Base):
    __tablename__ = "order_selection"

    __table_args__ = (
        CheckConstraint(
            "quantity > 0",
            name="ck_order_selection_quantity",
        ),
        UniqueConstraint(
            "customer_id",
            "address_id",
            "delivery_date",
            "category_id",
            "sub_category_id",
            name="uq_order_selection_assignment",
        ),
    )

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
        index=True,
        autoincrement=True,
    )

    customer_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "customers.id",
            onupdate="CASCADE",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    address_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "customer_addresses.id",
            onupdate="CASCADE",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    delivery_date: Mapped[date] = mapped_column(
        Date,
        nullable=False,
        index=True,
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

    sub_category_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "sub_categories.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=False,
    )

    quantity: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    # NULL means the assignment is still pending.

    selected_sub_category_id: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey(
            "sub_categories.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=True,
    )

    selected_item_id: Mapped[int | None] = mapped_column(
        Integer,
        ForeignKey(
            "hd_items.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=True,
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.now(),
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )
