from sqlalchemy.orm import Session

from app.repositories.inventory_subcategory import (
    InventorySubCategoryRepository,
)


class InventorySubCategoryService:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
        category_id: int | None = None,
        search: str | None = None,
    ):
        return InventorySubCategoryRepository.get_all(
            db=db,
            include_inactive=include_inactive,
            category_id=category_id,
            search=search,
        )

    @staticmethod
    def get_by_id(
        db: Session,
        subcategory_id: int,
    ):
        return InventorySubCategoryRepository.get_by_id(
            db=db,
            subcategory_id=subcategory_id,
        )

    @staticmethod
    def create(
        db: Session,
        category_id: int,
        name: str,
        status: bool = True,
    ):
        name = name.strip()

        if not name:
            raise ValueError("Subcategory name is required")

        existing = (
            InventorySubCategoryRepository.get_by_category_and_name(
                db=db,
                category_id=category_id,
                name=name,
            )
        )

        if existing:
            raise ValueError(
                "Subcategory already exists in this category"
            )

        return InventorySubCategoryRepository.create(
            db=db,
            category_id=category_id,
            name=name,
            status=status,
        )

    @staticmethod
    def update(
        db: Session,
        subcategory_id: int,
        category_id: int,
        name: str,
        status: bool,
    ):
        name = name.strip()

        if not name:
            raise ValueError("Subcategory name is required")

        subcategory = InventorySubCategoryRepository.get_by_id(
            db=db,
            subcategory_id=subcategory_id,
        )

        if not subcategory:
            raise LookupError("Subcategory not found")

        existing = (
            InventorySubCategoryRepository.get_by_category_and_name(
                db=db,
                category_id=category_id,
                name=name,
                exclude_id=subcategory_id,
            )
        )

        if existing:
            raise ValueError(
                "Subcategory already exists in this category"
            )

        return InventorySubCategoryRepository.update(
            db=db,
            subcategory=subcategory,
            category_id=category_id,
            name=name,
            status=status,
        )

    @staticmethod
    def update_status(
        db: Session,
        subcategory_id: int,
        status: bool,
    ):
        subcategory = InventorySubCategoryRepository.get_by_id(
            db=db,
            subcategory_id=subcategory_id,
        )

        if not subcategory:
            raise LookupError("Subcategory not found")

        return InventorySubCategoryRepository.update_status(
            db=db,
            subcategory=subcategory,
            status=status,
        )