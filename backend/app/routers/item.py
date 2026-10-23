
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.item import (
    ItemCreate,
    ItemResponse,
    ItemStatusUpdate,
    ItemUpdate,
)
from app.services.item import ItemService


router = APIRouter(
    prefix="/api/items",
    tags=["Items"],
)


def handle_integrity_error():
    raise HTTPException(
        status_code=409,
        detail=(
            "The item could not be saved because it conflicts "
            "with existing data. Check the item name and subcategory."
        ),
    )


@router.get(
    "/",
    response_model=list[ItemResponse],
)
def get_items(
    include_inactive: bool = Query(False),
    category_id: int | None = Query(None, gt=0),
    sub_category_id: int | None = Query(None, gt=0),
    search: str | None = Query(None, max_length=150),
    db: Session = Depends(get_db),
):
    return ItemService.get_items(
        db=db,
        include_inactive=include_inactive,
        category_id=category_id,
        sub_category_id=sub_category_id,
        search=search,
    )


@router.get(
    "/{item_id}",
    response_model=ItemResponse,
)
def get_item(
    item_id: int,
    db: Session = Depends(get_db),
):
    item = ItemService.get_item(db, item_id)

    if item is None:
        raise HTTPException(
            status_code=404,
            detail="Item not found",
        )

    return item


@router.post(
    "/",
    response_model=ItemResponse,
    status_code=201,
)
def create_item(
    data: ItemCreate,
    db: Session = Depends(get_db),
):
    try:
        return ItemService.create_item(db, data)

    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        ) from exc

    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail=(
                "The item name already exists in this category, "
                "or the submitted data conflicts with a database constraint."
            ),
        ) from exc


@router.put(
    "/{item_id}",
    response_model=ItemResponse,
)
def update_item(
    item_id: int,
    data: ItemUpdate,
    db: Session = Depends(get_db),
):
    try:
        item = ItemService.update_item(db, item_id, data)

        if item is None:
            raise HTTPException(
                status_code=404,
                detail="Item not found",
            )

        return item

    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        ) from exc

    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail=(
                "The item name already exists in this category, "
                "or the submitted data conflicts with a database constraint."
            ),
        ) from exc


@router.patch(
    "/{item_id}/status",
    response_model=ItemResponse,
)
def update_item_status(
    item_id: int,
    data: ItemStatusUpdate,
    db: Session = Depends(get_db),
):
    try:
        item = ItemService.update_status(db, item_id, data)

        if item is None:
            raise HTTPException(
                status_code=404,
                detail="Item not found",
            )

        return item

    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="Unable to update item status.",
        ) from exc
