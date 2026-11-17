
from sqlalchemy import (
    BigInteger,
    Boolean,
    ForeignKey,
    String,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class CustomerAddress(Base):
    __tablename__ = "customer_addresses"

    __table_args__ = (
        UniqueConstraint(
            "customer_id",
            "address_code",
            name="uq_customer_address_code",
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

    address_code: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    contact_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    contact_number: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )

    house_name: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True,
    )

    house_flat_number: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
    )

    address_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )

    country: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    state: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    district: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    area: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    street: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True,
    )

    landmark: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True,
    )

    pincode: Mapped[str] = mapped_column(
        String(6),
        nullable=False,
    )

    location_link: Mapped[str | None] = mapped_column(
        String(1000),
        nullable=True,
    )

    monthly_food_order: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=False,
    )

    customer = relationship(
        "Customer",
        back_populates="addresses",
    )
