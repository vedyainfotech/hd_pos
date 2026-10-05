from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.unit import (
    UnitCreate,
    UnitResponse,
    UnitStatusUpdate,
    UnitUpdate,
)
from app.services.unit import UnitService


router = APIRouter(
    prefix="/api/units",
    tags=["Units"],
)


@router.get("/", response_model=list[UnitResponse])
def get_units(
    include_inactive: bool = Query(False),
    db: Session = Depends(get_db),
):
    return UnitService.get_all(
        db,
        include_inactive=include_inactive,
    )


@router.get("/{unit_id}", response_model=UnitResponse)
def get_unit(
    unit_id: int,
    db: Session = Depends(get_db),
):
    return UnitService.get_by_id(db, unit_id)


@router.post(
    "/",
    response_model=UnitResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_unit(
    data: UnitCreate,
    db: Session = Depends(get_db),
):
    return UnitService.create(db, data)


@router.put(
    "/{unit_id}",
    response_model=UnitResponse,
)
def update_unit(
    unit_id: int,
    data: UnitUpdate,
    db: Session = Depends(get_db),
):
    return UnitService.update(
        db,
        unit_id,
        data,
    )


@router.patch(
    "/{unit_id}/status",
    response_model=UnitResponse,
)
def update_unit_status(
    unit_id: int,
    data: UnitStatusUpdate,
    db: Session = Depends(get_db),
):
    return UnitService.update_status(
        db,
        unit_id,
        data.status,
    )