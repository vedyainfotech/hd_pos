from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.inventory_subcategory import InventorySubCategory


class InventorySubCategoryRepository:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
        category_id: int | None = None,
        search: str | None = None,
    ):
        query = select(InventorySubCategory)

        if not include_inactive:
            query = query.where(
                InventorySubCategory.status.is_(True)
            )

        if category_id is not None:
            query = query.where(
                InventorySubCategory.category_id == category_id
            )

        if search and search.strip():
            query = query.where(
                InventorySubCategory.name.ilike(
                    f"%{search.strip()}%"
                )
            )

        query = query.order_by(
            InventorySubCategory.id.desc()
        )

        return db.scalars(query).all()

    @staticmethod
    def get_by_id(
        db: Session,
        subcategory_id: int,
    ):
        query = select(InventorySubCategory).where(
            InventorySubCategory.id == subcategory_id
        )

        return db.scalar(query)

    @staticmethod
    def get_by_category_and_name(
        db: Session,
        category_id: int,
        name: str,
        exclude_id: int | None = None,
    ):
        query = select(InventorySubCategory).where(
            InventorySubCategory.category_id == category_id,
            InventorySubCategory.name.ilike(name.strip()),
        )

        if exclude_id is not None:
            query = query.where(
                InventorySubCategory.id != exclude_id
            )

        return db.scalar(query)

    @staticmethod
    def create(
        db: Session,
        category_id: int,
        name: str,
        status: bool = True,
    ):
        subcategory = InventorySubCategory(
            category_id=category_id,
            name=name.strip(),
            status=status,
        )

        db.add(subcategory)
        db.commit()
        db.refresh(subcategory)

        return subcategory

    @staticmethod
    def update(
        db: Session,
        subcategory: InventorySubCategory,
        category_id: int,
        name: str,
        status: bool,
    ):
        subcategory.category_id = category_id
        subcategory.name = name.strip()
        subcategory.status = status

        db.commit()
        db.refresh(subcategory)

        return subcategory

    @staticmethod
    def update_status(
        db: Session,
        subcategory: InventorySubCategory,
        status: bool,
    ):
        subcategory.status = status

        db.commit()
        db.refresh(subcategory)

        return subcategory