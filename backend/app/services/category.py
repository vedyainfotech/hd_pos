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
        category = Category(
            name=data.name.strip(),
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

        category.name = data.name.strip()
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