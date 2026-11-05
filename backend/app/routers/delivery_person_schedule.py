
from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.delivery_person_schedule import (
    DeliveryPersonScheduleResponse,
    DeliveryPersonScheduleSave,
)
from app.services.delivery_person_schedule import (
    DeliveryPersonScheduleService,
)

router = APIRouter(
    prefix="/delivery-person-schedules",
    tags=["Delivery Person Schedules"],
)


@router.get("/", response_model=list[DeliveryPersonScheduleResponse])
def get_delivery_person_schedules(
    schedule_date: date,
    db: Session = Depends(get_db),
):
    return DeliveryPersonScheduleService.get_schedule(
        db=db,
        schedule_date=schedule_date,
    )


@router.put("/", response_model=list[DeliveryPersonScheduleResponse])
def save_delivery_person_schedule(
    payload: DeliveryPersonScheduleSave,
    db: Session = Depends(get_db),
):
    try:
        return DeliveryPersonScheduleService.save_category_schedule(
            db=db,
            schedule_date=payload.schedule_date,
            category_id=payload.category_id,
            delivery_person_ids=payload.delivery_person_ids,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=404,
            detail=str(exc),
        ) from exc
