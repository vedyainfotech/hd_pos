from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.inventory_category import (
    InventoryCategoryCreate,
    InventoryCategoryResponse,
    InventoryCategoryStatusUpdate,
    InventoryCategoryUpdate,
)
from app.services.inventory_category import (
    InventoryCategoryService,
)


router = APIRouter(
    prefix="/api/inventory-categories",
    tags=["Inventory Categories"],
)


@router.get(
    "/",
    response_model=list[InventoryCategoryResponse],
)
def get_inventory_categories(
    include_inactive: bool = Query(False),
    db: Session = Depends(get_db),
):
    return InventoryCategoryService.get_all(
        db,
        include_inactive=include_inactive,
    )


@router.get(
    "/{category_id}",
    response_model=InventoryCategoryResponse,
)
def get_inventory_category(
    category_id: int,
    db: Session = Depends(get_db),
):
    return InventoryCategoryService.get_by_id(
        db,
        category_id,
    )


@router.post(
    "/",
    response_model=InventoryCategoryResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_inventory_category(
    data: InventoryCategoryCreate,
    db: Session = Depends(get_db),
):
    return InventoryCategoryService.create(
        db,
        data,
    )


@router.put(
    "/{category_id}",
    response_model=InventoryCategoryResponse,
)
def update_inventory_category(
    category_id: int,
    data: InventoryCategoryUpdate,
    db: Session = Depends(get_db),
):
    return InventoryCategoryService.update(
        db,
        category_id,
        data,
    )


@router.patch(
    "/{category_id}/status",
    response_model=InventoryCategoryResponse,
)
def update_inventory_category_status(
    category_id: int,
    data: InventoryCategoryStatusUpdate,
    db: Session = Depends(get_db),
):
    return InventoryCategoryService.update_status(
        db,
        category_id,
        data.status,
    )