from datetime import time

from sqlalchemy import BigInteger, Boolean, String, Time
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Category(Base):
    __tablename__ = "categories"

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
        index=True,
    )

    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    allotment_time: Mapped[time] = mapped_column(
        Time,
        nullable=False,
        default=time(23, 55, 0),
    )

    status: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )