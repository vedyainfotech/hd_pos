from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.category import (
    CategoryCreate,
    CategoryResponse,
    CategoryStatusUpdate,
    CategoryUpdate,
)
from app.services.category import CategoryService


router = APIRouter(
    prefix="/api/categories",
    tags=["Categories"],
)


@router.get(
    "/",
    response_model=list[CategoryResponse],
)
def get_categories(
    include_inactive: bool = Query(False),
    db: Session = Depends(get_db),
):
    return CategoryService.get_categories(
        db,
        include_inactive,
    )


@router.get(
    "/{category_id}",
    response_model=CategoryResponse,
)
def get_category(
    category_id: int,
    db: Session = Depends(get_db),
):
    category = CategoryService.get_category(
        db,
        category_id,
    )

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found",
        )

    return category


@router.post(
    "/",
    response_model=CategoryResponse,
    status_code=201,
)
def create_category(
    data: CategoryCreate,
    db: Session = Depends(get_db),
):
    existing_category = CategoryService.get_category(
        db,
        0,
    )

    category = CategoryService.create_category(
        db,
        data,
    )

    return category


@router.put(
    "/{category_id}",
    response_model=CategoryResponse,
)
def update_category(
    category_id: int,
    data: CategoryUpdate,
    db: Session = Depends(get_db),
):
    category = CategoryService.update_category(
        db,
        category_id,
        data,
    )

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found",
        )

    return category


@router.patch(
    "/{category_id}/status",
    response_model=CategoryResponse,
)
def update_category_status(
    category_id: int,
    data: CategoryStatusUpdate,
    db: Session = Depends(get_db),
):
    category = CategoryService.update_status(
        db,
        category_id,
        data,
    )

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found",
        )

    return category