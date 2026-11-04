from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.inventory_category import InventoryCategory


class InventoryCategoryRepository:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
    ):
        query = select(InventoryCategory).order_by(
            InventoryCategory.id
        )

        if not include_inactive:
            query = query.where(
                InventoryCategory.status.is_(True)
            )

        return list(db.scalars(query).all())

    @staticmethod
    def get_by_id(
        db: Session,
        category_id: int,
    ):
        return db.get(
            InventoryCategory,
            category_id,
        )

    @staticmethod
    def get_by_name(
        db: Session,
        name: str,
    ):
        normalized_name = "".join(
            name.split()
        ).lower()

        categories = db.scalars(
            select(InventoryCategory)
        ).all()

        for category in categories:
            existing_name = "".join(
                category.name.split()
            ).lower()

            if existing_name == normalized_name:
                return category

        return None

    @staticmethod
    def create(
        db: Session,
        category: InventoryCategory,
    ):
        db.add(category)
        db.commit()
        db.refresh(category)

        return category

    @staticmethod
    def update(
        db: Session,
        category: InventoryCategory,
    ):
        db.commit()
        db.refresh(category)

        return category