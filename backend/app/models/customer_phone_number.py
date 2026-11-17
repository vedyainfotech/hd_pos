
from sqlalchemy import (
    BigInteger,
    ForeignKey,
    String,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class CustomerPhoneNumber(Base):
    __tablename__ = "customer_phone_numbers"

    __table_args__ = (
        UniqueConstraint(
            "customer_id",
            "phone_number",
            name="uq_customer_phone",
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

    phone_number: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        index=True,
    )

    customer = relationship(
        "Customer",
        back_populates="phone_numbers",
    )
