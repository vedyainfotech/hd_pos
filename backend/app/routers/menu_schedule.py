from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db

from app.schemas.menu_schedule import (
    MenuScheduleSave,
    MenuScheduleDateResponse,
    AvailableMenuResponse,
)

from app.services import menu_schedule as service


router = APIRouter(
    prefix="/api/menu-scheduling",
    tags=["Menu Scheduling"],
)


# ---------------------------------
# Get Available Menu Items
# ---------------------------------

@router.get(
    "/available-items",
    response_model=AvailableMenuResponse,
)
def get_available_menu_items(
    category_id: int = Query(..., gt=0),
    search: str | None = Query(None),
    db: Session = Depends(get_db),
):
    return service.get_available_menu(
        db=db,
        category_id=category_id,
        search=search,
    )


# ---------------------------------
# Get Scheduled Menu by Date
# ---------------------------------

@router.get(
    "/date/{delivery_date}",
    response_model=MenuScheduleDateResponse,
)
def get_menu_schedule_by_date(
    delivery_date: date,
    db: Session = Depends(get_db),
):
    return service.get_menu_by_date(
        db=db,
        delivery_date=delivery_date,
    )


# ---------------------------------
# Save or Update Menu Schedule
# ---------------------------------

@router.put("/save")
def save_menu_schedule(
    request: MenuScheduleSave,
    db: Session = Depends(get_db),
):
    return service.save_menu_schedule(
        db=db,
        delivery_date=request.delivery_date,
        category_id=request.category_id,
        item_ids=request.item_ids,
    )