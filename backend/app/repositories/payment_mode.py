
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.payment_mode import PaymentMode


def get_payment_modes(
    db: Session,
    include_inactive: bool = True,
):
    query = db.query(PaymentMode)

    if not include_inactive:
        query = query.filter(
            PaymentMode.status.is_(True)
        )

    return query.order_by(PaymentMode.id).all()


def get_payment_mode(
    db: Session,
    payment_mode_id: int,
):
    return (
        db.query(PaymentMode)
        .filter(PaymentMode.id == payment_mode_id)
        .first()
    )


def get_payment_mode_by_name(
    db: Session,
    name: str,
    exclude_id: int | None = None,
):
    # Ignore uppercase/lowercase differences and all whitespace.
    normalized_input = func.lower(
        func.regexp_replace(
            func.trim(name),
            r'\s+',
            '',
            'g',
        )
    )

    normalized_column = func.lower(
        func.regexp_replace(
            func.trim(PaymentMode.name),
            r'\s+',
            '',
            'g',
        )
    )

    query = select(PaymentMode).where(
        normalized_column == normalized_input
    )

    if exclude_id is not None:
        query = query.where(
            PaymentMode.id != exclude_id
        )

    return db.scalar(query)


def create_payment_mode(
    db: Session,
    name: str,
    status: bool,
):
    payment_mode = PaymentMode(
        name=name,
        status=status,
    )

    db.add(payment_mode)
    db.commit()
    db.refresh(payment_mode)

    return payment_mode


def update_payment_mode(
    db: Session,
    payment_mode: PaymentMode,
    name: str,
    status: bool,
):
    payment_mode.name = name
    payment_mode.status = status

    db.commit()
    db.refresh(payment_mode)

    return payment_mode
