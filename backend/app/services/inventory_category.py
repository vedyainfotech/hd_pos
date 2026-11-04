from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.inventory_category import InventoryCategory
from app.repositories.inventory_category import (
    InventoryCategoryRepository,
)
from app.schemas.inventory_category import (
    InventoryCategoryCreate,
    InventoryCategoryUpdate,
)


class InventoryCategoryService:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
    ):
        return InventoryCategoryRepository.get_all(
            db,
            include_inactive=include_inactive,
        )

    @staticmethod
    def get_by_id(
        db: Session,
        category_id: int,
    ):
        category = InventoryCategoryRepository.get_by_id(
            db,
            category_id,
        )

        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Inventory category not found",
            )

        return category

    @staticmethod
    def create(
        db: Session,
        data: InventoryCategoryCreate,
    ):
        name = data.name.strip()

        if not name:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Inventory category name is required",
            )

        existing = InventoryCategoryRepository.get_by_name(
            db,
            name,
        )

        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Inventory category already exists",
            )

        category = InventoryCategory(
            name=name,
            status=True,
        )

        return InventoryCategoryRepository.create(
            db,
            category,
        )

    @staticmethod
    def update(
        db: Session,
        category_id: int,
        data: InventoryCategoryUpdate,
    ):
        category = InventoryCategoryService.get_by_id(
            db,
            category_id,
        )

        name = data.name.strip()

        if not name:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Inventory category name is required",
            )

        existing = InventoryCategoryRepository.get_by_name(
            db,
            name,
        )

        if existing and existing.id != category_id:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Inventory category already exists",
            )

        category.name = name
        category.status = data.status

        return InventoryCategoryRepository.update(
            db,
            category,
        )

    @staticmethod
    def update_status(
        db: Session,
        category_id: int,
        status_value: bool,
    ):
        category = InventoryCategoryService.get_by_id(
            db,
            category_id,
        )

        category.status = status_value

        return InventoryCategoryRepository.update(
            db,
            category,
        )