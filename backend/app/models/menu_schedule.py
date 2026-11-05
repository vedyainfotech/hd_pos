from datetime import date, datetime

from sqlalchemy import (
    BigInteger,
    Integer,
    Date,
    DateTime,
    ForeignKey,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class MenuSchedule(Base):
    __tablename__ = "menu_schedules"

    __table_args__ = (
        UniqueConstraint(
            "delivery_date",
            "category_id",
            name="uq_menu_schedule_date_category",
        ),
    )

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
        index=True,
    )

    delivery_date: Mapped[date] = mapped_column(
        Date,
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


class MenuScheduleItem(Base):
    __tablename__ = "menu_schedule_items"

    __table_args__ = (
        UniqueConstraint(
            "schedule_id",
            "item_id",
            name="uq_menu_schedule_item",
        ),
    )

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
        index=True,
    )

    schedule_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey(
            "menu_schedules.id",
            onupdate="CASCADE",
            ondelete="CASCADE",
        ),
        nullable=False,
    )

    item_id: Mapped[int] = mapped_column(
        Integer,
        ForeignKey(
            "hd_items.id",
            onupdate="CASCADE",
            ondelete="RESTRICT",
        ),
        nullable=False,
    )