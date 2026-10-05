from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.inventory_subcategory import (
    InventorySubCategoryCreate,
    InventorySubCategoryResponse,
    InventorySubCategoryStatusUpdate,
    InventorySubCategoryUpdate,
)
from app.services.inventory_subcategory import (
    InventorySubCategoryService,
)


router = APIRouter(
    prefix="/api/inventory-subcategories",
    tags=["Inventory Sub Categories"],
)


@router.get(
    "/",
    response_model=list[InventorySubCategoryResponse],
)
def get_subcategories(
    include_inactive: bool = Query(False),
    category_id: int | None = Query(None),
    search: str | None = Query(None),
    db: Session = Depends(get_db),
):
    return InventorySubCategoryService.get_all(
        db=db,
        include_inactive=include_inactive,
        category_id=category_id,
        search=search,
    )


@router.get(
    "/{subcategory_id}",
    response_model=InventorySubCategoryResponse,
)
def get_subcategory(
    subcategory_id: int,
    db: Session = Depends(get_db),
):
    subcategory = InventorySubCategoryService.get_by_id(
        db=db,
        subcategory_id=subcategory_id,
    )

    if not subcategory:
        raise HTTPException(
            status_code=404,
            detail="Subcategory not found",
        )

    return subcategory


@router.post(
    "/",
    response_model=InventorySubCategoryResponse,
    status_code=201,
)
def create_subcategory(
    data: InventorySubCategoryCreate,
    db: Session = Depends(get_db),
):
    try:
        return InventorySubCategoryService.create(
            db=db,
            category_id=data.category_id,
            name=data.name,
            status=data.status,
        )
    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error),
        )


@router.put(
    "/{subcategory_id}",
    response_model=InventorySubCategoryResponse,
)
def update_subcategory(
    subcategory_id: int,
    data: InventorySubCategoryUpdate,
    db: Session = Depends(get_db),
):
    try:
        return InventorySubCategoryService.update(
            db=db,
            subcategory_id=subcategory_id,
            category_id=data.category_id,
            name=data.name,
            status=data.status,
        )
    except LookupError as error:
        raise HTTPException(
            status_code=404,
            detail=str(error),
        )
    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error),
        )


@router.patch(
    "/{subcategory_id}/status",
    response_model=InventorySubCategoryResponse,
)
def update_subcategory_status(
    subcategory_id: int,
    data: InventorySubCategoryStatusUpdate,
    db: Session = Depends(get_db),
):
    try:
        return InventorySubCategoryService.update_status(
            db=db,
            subcategory_id=subcategory_id,
            status=data.status,
        )
    except LookupError as error:
        raise HTTPException(
            status_code=404,
            detail=str(error),
        )