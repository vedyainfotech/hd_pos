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


def create_payment_mode(
    db: Session,
    name: str,
    status: bool,
):
    payment_mode = PaymentMode(
        name=name
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