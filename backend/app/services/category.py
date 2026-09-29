from sqlalchemy.orm import Session

from app.models.category import Category
from app.repositories.category import CategoryRepository
from app.schemas.category import (
    CategoryCreate,
    CategoryStatusUpdate,
    CategoryUpdate,
)


class CategoryService:

    # ============================================================
    # GET ALL
    # ============================================================

    @staticmethod
    def get_categories(
        db: Session,
        include_inactive: bool = False,
    ):

        return CategoryRepository.get_all(
            db,
            include_inactive,
        )

    # ============================================================
    # GET ONE
    # ============================================================

    @staticmethod
    def get_category(
        db: Session,
        category_id: int,
    ):

        return CategoryRepository.get_by_id(
            db,
            category_id,
        )

    # ============================================================
    # CREATE
    # ============================================================

    @staticmethod
    def create_category(
        db: Session,
        data: CategoryCreate,
    ):

        # Check normalized duplicate.
        existing = CategoryRepository.get_by_name(
            db,
            data.name,
        )

        if existing is not None:
            raise ValueError(
                "Category already exists"
            )

        category = Category(
            name=data.name.strip(),
            allotment_time=data.allotment_time,
            status=data.status,
        )

        return CategoryRepository.create(
            db,
            category,
        )

    # ============================================================
    # UPDATE
    # ============================================================

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

        # Don't allow another category to have the same
        # normalized name.
        existing = CategoryRepository.get_by_name(
            db,
            data.name,
            exclude_id=category_id,
        )

        if existing is not None:
            raise ValueError(
                "Category already exists"
            )

        category.name = data.name.strip()
        category.allotment_time = data.allotment_time
        category.status = data.status

        return CategoryRepository.update(
            db,
            category,
        )

    # ============================================================
    # UPDATE STATUS
    # ============================================================

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