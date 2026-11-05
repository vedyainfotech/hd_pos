from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.repositories import hd_items as repository


def list_items(
    db: Session,
    include_inactive: bool = False,
    category_id: int | None = None,
    sub_category_id: int | None = None,
    search: str | None = None,
):
    return repository.get_items(
        db=db,
        include_inactive=include_inactive,
        category_id=category_id,
        sub_category_id=sub_category_id,
        search=search,
    )


def create_item(db: Session, item_data: dict):
    name = item_data["name"].strip()

    if not name:
        raise HTTPException(status_code=400, detail="Item name is required")

    if repository.get_item_by_name(db, name):
        raise HTTPException(
            status_code=409,
            detail="Item already exists",
        )

    item_data["name"] = name
    return repository.create_item(db, item_data)


def update_item(db: Session, item_id: int, item_data: dict):
    item = repository.get_item(db, item_id)

    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    name = item_data["name"].strip()

    if not name:
        raise HTTPException(status_code=400, detail="Item name is required")

    duplicate = repository.get_item_by_name(db, name)

    if duplicate and duplicate.id != item_id:
        raise HTTPException(
            status_code=409,
            detail="Item already exists",
        )

    item_data["name"] = name
    return repository.update_item(db, item, item_data)


def update_status(db: Session, item_id: int, status: bool):
    item = repository.get_item(db, item_id)

    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    return repository.update_item_status(db, item, status)