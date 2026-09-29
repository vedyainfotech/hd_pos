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


@router.get(
    "/",
    response_model=list[ItemResponse],
)
def get_items(
    include_inactive: bool = Query(True),
    category_id: int | None = Query(None),
    sub_category_id: int | None = Query(None),
    search: str | None = Query(None),
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
    item = ItemService.get_item(
        db,
        item_id,
    )

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
        return ItemService.create_item(
            db,
            data,
        )

    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )

    except IntegrityError:
        db.rollback()

        raise HTTPException(
            status_code=409,
            detail="Item already exists under this sub category",
        )


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
        item = ItemService.update_item(
            db,
            item_id,
            data,
        )

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
        )

    except IntegrityError:
        db.rollback()

        raise HTTPException(
            status_code=409,
            detail="Item already exists under this sub category",
        )


@router.patch(
    "/{item_id}/status",
    response_model=ItemResponse,
)
def update_item_status(
    item_id: int,
    data: ItemStatusUpdate,
    db: Session = Depends(get_db),
):
    item = ItemService.update_status(
        db,
        item_id,
        data,
    )

    if item is None:
        raise HTTPException(
            status_code=404,
            detail="Item not found",
        )

    return item