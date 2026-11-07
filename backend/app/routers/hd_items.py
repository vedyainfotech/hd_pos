from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.hd_items import (
    HDItemCreate,
    HDItemUpdate,
    HDItemResponse,
    HDItemStatusUpdate,
)
from app.services import hd_items as service


router = APIRouter(
    prefix="/api/hd-items",
    tags=["Home Delivery Items"],
)


@router.get("/", response_model=list[HDItemResponse])
def get_items(
    include_inactive: bool = Query(False),
    category_id: int | None = Query(None),
    sub_category_id: int | None = Query(None),
    search: str | None = Query(None),
    db: Session = Depends(get_db),
):
    return service.list_items(
        db,
        include_inactive,
        category_id,
        sub_category_id,
        search,
    )


@router.post("/", response_model=HDItemResponse, status_code=201)
def create_item(
    item_data: HDItemCreate,
    db: Session = Depends(get_db),
):
    return service.create_item(
        db,
        item_data.model_dump(),
    )


@router.put("/{item_id}", response_model=HDItemResponse)
def update_item(
    item_id: int,
    item_data: HDItemUpdate,
    db: Session = Depends(get_db),
):
    return service.update_item(
        db,
        item_id,
        item_data.model_dump(),
    )


@router.patch("/{item_id}/status", response_model=HDItemResponse)
def update_item_status(
    item_id: int,
    status_data: HDItemStatusUpdate,
    db: Session = Depends(get_db),
):
    return service.update_status(
        db,
        item_id,
        status_data.status,
    )