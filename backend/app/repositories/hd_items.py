from sqlalchemy.orm import Session
from app.models.hd_items import HDItem


def get_items(
    db: Session,
    include_inactive: bool = False,
    category_id: int | None = None,
    sub_category_id: int | None = None,
    search: str | None = None,
):
    query = db.query(HDItem)

    if not include_inactive:
        query = query.filter(HDItem.status.is_(True))

    if category_id is not None:
        query = query.filter(HDItem.category_id == category_id)

    if sub_category_id is not None:
        query = query.filter(HDItem.sub_category_id == sub_category_id)

    if search:
        query = query.filter(HDItem.name.ilike(f"%{search.strip()}%"))

    return query.order_by(HDItem.id.desc()).all()


def get_item(db: Session, item_id: int):
    return db.query(HDItem).filter(HDItem.id == item_id).first()


def get_item_by_name(db: Session, name: str):
    return (
        db.query(HDItem)
        .filter(HDItem.name.ilike(name.strip()))
        .first()
    )


def create_item(db: Session, item_data: dict):
    item = HDItem(**item_data)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def update_item(db: Session, item: HDItem, item_data: dict):
    for key, value in item_data.items():
        setattr(item, key, value)

    db.commit()
    db.refresh(item)
    return item


def update_item_status(db: Session, item: HDItem, status: bool):
    item.status = status
    db.commit()
    db.refresh(item)
    return item