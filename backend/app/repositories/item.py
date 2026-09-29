from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.item import Item


class ItemRepository:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
        category_id: int | None = None,
        sub_category_id: int | None = None,
        search: str | None = None,
    ) -> list[Item]:
        query = select(Item)

        if not include_inactive:
            query = query.where(Item.status.is_(True))

        if category_id is not None:
            query = query.where(
                Item.category_id == category_id
            )

        if sub_category_id is not None:
            query = query.where(
                Item.sub_category_id == sub_category_id
            )

        if search:
            search_value = search.strip()

            if search_value:
                query = query.where(
                    Item.name.ilike(
                        f"%{search_value}%"
                    )
                )

        query = query.order_by(Item.id)

        return list(
            db.scalars(query).all()
        )

    @staticmethod
    def get_by_id(
        db: Session,
        item_id: int,
    ) -> Item | None:
        query = select(Item).where(
            Item.id == item_id
        )

        return db.scalar(query)

    @staticmethod
    def get_by_name(
        db: Session,
        sub_category_id: int,
        name: str,
        exclude_id: int | None = None,
    ) -> Item | None:
        normalized_input = func.lower(
            func.regexp_replace(
                func.trim(name),
                r"\s+",
                "",
                "g",
            )
        )

        normalized_column = func.lower(
            func.regexp_replace(
                func.trim(Item.name),
                r"\s+",
                "",
                "g",
            )
        )

        query = select(Item).where(
            Item.sub_category_id == sub_category_id,
            normalized_column == normalized_input,
        )

        if exclude_id is not None:
            query = query.where(
                Item.id != exclude_id
            )

        return db.scalar(query)

    @staticmethod
    def create(
        db: Session,
        item: Item,
    ) -> Item:
        db.add(item)
        db.commit()
        db.refresh(item)

        return item

    @staticmethod
    def update(
        db: Session,
        item: Item,
    ) -> Item:
        db.commit()
        db.refresh(item)

        return item

    @staticmethod
    def update_status(
        db: Session,
        item: Item,
        status: bool,
    ) -> Item:
        item.status = status

        db.commit()
        db.refresh(item)

        return item