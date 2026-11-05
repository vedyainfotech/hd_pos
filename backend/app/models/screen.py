from sqlalchemy import Boolean, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Screen(Base):
    __tablename__ = "screens"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    screen_key: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        unique=True,
    )

    screen_name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    route_name: Mapped[str] = mapped_column(
        String(200),
        nullable=False,
        unique=True,
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )