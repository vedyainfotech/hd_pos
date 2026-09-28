from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.repositories import payment_mode as payment_mode_repository


def get_payment_modes(
    db: Session,
    include_inactive: bool = True,
):
    return payment_mode_repository.get_payment_modes(
        db,
        include_inactive,
    )


def get_payment_mode(
    db: Session,
    payment_mode_id: int,
):
    payment_mode = payment_mode_repository.get_payment_mode(
        db,
        payment_mode_id,
    )

    if payment_mode is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment mode not found",
        )

    return payment_mode


def create_payment_mode(
    db: Session,
    name: str,
    status: bool = True,
):
    name = name.strip()

    if not name:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment mode name cannot be empty",
        )

    return payment_mode_repository.create_payment_mode(
        db,
        name=name,
        status=status,
    )


def update_payment_mode(
    db: Session,
    payment_mode_id: int,
    name: str,
    status: bool,
):
    payment_mode = get_payment_mode(
        db,
        payment_mode_id,
    )

    name = name.strip()

    if not name:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment mode name cannot be empty",
        )

    return payment_mode_repository.update_payment_mode(
        db,
        payment_mode,
        name=name,
        status=status,
    )


def update_payment_mode_status(
    db: Session,
    payment_mode_id: int,
    status: bool,
):
    payment_mode = get_payment_mode(
        db,
        payment_mode_id,
    )

    return payment_mode_repository.update_payment_mode(
        db,
        payment_mode,
        name=payment_mode.name,
        status=status,
    )