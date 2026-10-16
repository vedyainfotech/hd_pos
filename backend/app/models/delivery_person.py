from sqlalchemy import BigInteger, Boolean, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class DeliveryPerson(Base):
    __tablename__ = "delivery_persons"

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
        index=True,
    )

    name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    contact_number: Mapped[str] = mapped_column(
        String(10),
        nullable=False,
        index=True,
    )

    bank_name: Mapped[str | None] = mapped_column(
        String(150),
        nullable=True,
    )

    account_number: Mapped[str | None] = mapped_column(
        String(18),
        nullable=True,
    )

    ifsc_code: Mapped[str | None] = mapped_column(
        String(11),
        nullable=True,
    )

    aadhaar_number: Mapped[str | None] = mapped_column(
        String(12),
        nullable=True,
    )

    pan_card_number: Mapped[str | None] = mapped_column(
        String(10),
        nullable=True,
    )

    driving_license: Mapped[str | None] = mapped_column(
        String(30),
        nullable=True,
    )

    # Identity proof document metadata.
    # The actual file is stored in backend/uploads/delivery_persons/.
    identity_proof_filename: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )

    identity_proof_path: Mapped[str] = mapped_column(
        String(500),
        nullable=False,
    )

    identity_proof_content_type: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    identity_proof_size: Mapped[int] = mapped_column(
        BigInteger,
        nullable=False,
    )

    status: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )