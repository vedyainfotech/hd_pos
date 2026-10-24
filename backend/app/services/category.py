
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.category import Category
from app.repositories.category import CategoryRepository
from app.schemas.category import (
    CategoryCreate,
    CategoryStatusUpdate,
    CategoryUpdate,
)


class CategoryService:

    @staticmethod
    def get_categories(
        db: Session,
        include_inactive: bool = False,
    ):
        return CategoryRepository.get_all(
            db,
            include_inactive,
        )

    @staticmethod
    def get_category(
        db: Session,
        category_id: int,
    ):
        return CategoryRepository.get_by_id(
            db,
            category_id,
        )

    @staticmethod
    def create_category(
        db: Session,
        data: CategoryCreate,
    ):
        name = data.name.strip()

        if not name:
            raise HTTPException(
                status_code=400,
                detail="Category name is required",
            )

        # Reject duplicate names, ignoring case and all whitespace.
        existing = CategoryRepository.get_by_name(
            db,
            name,
        )

        if existing is not None:
            raise HTTPException(
                status_code=409,
                detail="Category already exists",
            )

        category = Category(
            name=name,
            allotment_time=data.allotment_time,
            status=data.status,
        )

        return CategoryRepository.create(
            db,
            category,
        )

    @staticmethod
    def update_category(
        db: Session,
        category_id: int,
        data: CategoryUpdate,
    ):
        category = CategoryRepository.get_by_id(
            db,
            category_id,
        )

        if category is None:
            return None

        name = data.name.strip()

        if not name:
            raise HTTPException(
                status_code=400,
                detail="Category name is required",
            )

        # Exclude the current category so its existing name is allowed.
        existing = CategoryRepository.get_by_name(
            db,
            name,
            exclude_id=category_id,
        )

        if existing is not None:
            raise HTTPException(
                status_code=409,
                detail="Category already exists",
            )

        category.name = name
        category.allotment_time = data.allotment_time
        category.status = data.status

        return CategoryRepository.update(
            db,
            category,
        )

    @staticmethod
    def update_status(
        db: Session,
        category_id: int,
        data: CategoryStatusUpdate,
    ):
        category = CategoryRepository.get_by_id(
            db,
            category_id,
        )

        if category is None:
            return None

        return CategoryRepository.update_status(
            db,
            category,
            data.status,
        )
