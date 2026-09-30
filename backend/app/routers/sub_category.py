from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.sub_category import (
    SubCategoryCreate,
    SubCategoryResponse,
    SubCategoryStatusUpdate,
    SubCategoryUpdate,
)
from app.services.sub_category import SubCategoryService


router = APIRouter(
    prefix="/api/sub-categories",
    tags=["Sub Categories"],
)


# ============================================================
# GET ALL SUB CATEGORIES
# ============================================================

@router.get(
    "/",
    response_model=list[SubCategoryResponse],
)
def get_sub_categories(
    include_inactive: bool = Query(True),
    category_id: int | None = Query(None),
    search: str | None = Query(None),
    db: Session = Depends(get_db),
):

    return SubCategoryService.get_sub_categories(
        db=db,
        include_inactive=include_inactive,
        category_id=category_id,
        search=search,
    )


# ============================================================
# GET ONE SUB CATEGORY
# ============================================================

@router.get(
    "/{sub_category_id}",
    response_model=SubCategoryResponse,
)
def get_sub_category(
    sub_category_id: int,
    db: Session = Depends(get_db),
):

    sub_category = SubCategoryService.get_sub_category(
        db,
        sub_category_id,
    )

    if sub_category is None:
        raise HTTPException(
            status_code=404,
            detail="Sub category not found",
        )

    return sub_category


# ============================================================
# CREATE
# ============================================================

@router.post(
    "/",
    response_model=SubCategoryResponse,
    status_code=201,
)
def create_sub_category(
    data: SubCategoryCreate,
    db: Session = Depends(get_db),
):

    try:

        sub_category = SubCategoryService.create_sub_category(
            db,
            data,
        )

        return sub_category

    except ValueError as exc:

        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )

    except IntegrityError:

        db.rollback()

        raise HTTPException(
            status_code=409,
            detail=(
                "Sub category already exists "
                "under this category"
            ),
        )


# ============================================================
# UPDATE
# ============================================================

@router.put(
    "/{sub_category_id}",
    response_model=SubCategoryResponse,
)
def update_sub_category(
    sub_category_id: int,
    data: SubCategoryUpdate,
    db: Session = Depends(get_db),
):

    try:

        sub_category = SubCategoryService.update_sub_category(
            db,
            sub_category_id,
            data,
        )

        if sub_category is None:
            raise HTTPException(
                status_code=404,
                detail="Sub category not found",
            )

        return sub_category

    except ValueError as exc:

        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )

    except IntegrityError:

        db.rollback()

        raise HTTPException(
            status_code=409,
            detail=(
                "Sub category already exists "
                "under this category"
            ),
        )


# ============================================================
# UPDATE STATUS
# ============================================================

@router.patch(
    "/{sub_category_id}/status",
    response_model=SubCategoryResponse,
)
def update_sub_category_status(
    sub_category_id: int,
    data: SubCategoryStatusUpdate,
    db: Session = Depends(get_db),
):

    sub_category = SubCategoryService.update_status(
        db,
        sub_category_id,
        data,
    )

    if sub_category is None:
        raise HTTPException(
            status_code=404,
            detail="Sub category not found",
        )

    return sub_category