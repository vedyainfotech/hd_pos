from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.payment_mode import (
    PaymentModeCreate,
    PaymentModeResponse,
    PaymentModeStatusUpdate,
    PaymentModeUpdate,
)
from app.services.payment_mode import (
    create_payment_mode,
    get_payment_mode,
    get_payment_modes,
    update_payment_mode,
    update_payment_mode_status,
)

router = APIRouter(
    prefix="/api/payment-modes",
    tags=["Payment Modes"],
)


@router.get(
    "",
    response_model=list[PaymentModeResponse],
)
def get_all_payment_modes(
    include_inactive: bool = True,
    db: Session = Depends(get_db),
):
    return get_payment_modes(
        db,
        include_inactive,
    )


@router.get(
    "/{payment_mode_id}",
    response_model=PaymentModeResponse,
)
def get_single_payment_mode(
    payment_mode_id: int,
    db: Session = Depends(get_db),
):
    return get_payment_mode(
        db,
        payment_mode_id,
    )


@router.post(
    "",
    response_model=PaymentModeResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_new_payment_mode(
    data: PaymentModeCreate,
    db: Session = Depends(get_db),
):
    return create_payment_mode(
        db,
        name=data.name,
        status=data.status,
    )


@router.put(
    "/{payment_mode_id}",
    response_model=PaymentModeResponse,
)
def update_existing_payment_mode(
    payment_mode_id: int,
    data: PaymentModeUpdate,
    db: Session = Depends(get_db),
):
    return update_payment_mode(
        db,
        payment_mode_id,
        name=data.name,
        status=data.status,
    )


@router.patch(
    "/{payment_mode_id}/status",
    response_model=PaymentModeResponse,
)
def update_payment_mode_active_status(
    payment_mode_id: int,
    data: PaymentModeStatusUpdate,
    db: Session = Depends(get_db),
):
    return update_payment_mode_status(
        db,
        payment_mode_id,
        data.status,
    )