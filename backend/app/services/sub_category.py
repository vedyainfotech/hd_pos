from sqlalchemy.orm import Session

from app.models.category import Category
from app.models.sub_category import SubCategory
from app.repositories.sub_category import (
    SubCategoryRepository,
)
from app.schemas.sub_category import (
    SubCategoryCreate,
    SubCategoryStatusUpdate,
    SubCategoryUpdate,
)


class SubCategoryService:

    @staticmethod
    def get_sub_categories(
        db: Session,
        include_inactive: bool = False,
        category_id: int | None = None,
        search: str | None = None,
    ):
        return SubCategoryRepository.get_all(
            db=db,
            include_inactive=include_inactive,
            category_id=category_id,
            search=search,
        )

    @staticmethod
    def get_sub_category(
        db: Session,
        sub_category_id: int,
    ):
        return SubCategoryRepository.get_by_id(
            db,
            sub_category_id,
        )

    @staticmethod
    def create_sub_category(
        db: Session,
        data: SubCategoryCreate,
    ):
        category = db.get(
            Category,
            data.category_id,
        )

        if category is None:
            raise ValueError(
                "Category not found"
            )

        existing = (
            SubCategoryRepository.get_by_name(
                db=db,
                category_id=data.category_id,
                name=data.name,
            )
        )

        if existing is not None:
            raise ValueError(
                "Sub category already exists under this category"
            )

        sub_category = SubCategory(
            category_id=data.category_id,
            name=data.name.strip(),
            price=data.price,
            status=True,
        )

        return SubCategoryRepository.create(
            db,
            sub_category,
        )

    @staticmethod
    def update_sub_category(
        db: Session,
        sub_category_id: int,
        data: SubCategoryUpdate,
    ):
        sub_category = (
            SubCategoryRepository.get_by_id(
                db,
                sub_category_id,
            )
        )

        if sub_category is None:
            return None

        category = db.get(
            Category,
            data.category_id,
        )

        if category is None:
            raise ValueError(
                "Category not found"
            )

        existing = (
            SubCategoryRepository.get_by_name(
                db=db,
                category_id=data.category_id,
                name=data.name,
                exclude_id=sub_category_id,
            )
        )

        if existing is not None:
            raise ValueError(
                "Sub category already exists under this category"
            )

        sub_category.category_id = (
            data.category_id
        )

        sub_category.name = (
            data.name.strip()
        )

        sub_category.price = data.price

        sub_category.status = data.status

        return SubCategoryRepository.update(
            db,
            sub_category,
        )

    @staticmethod
    def update_status(
        db: Session,
        sub_category_id: int,
        data: SubCategoryStatusUpdate,
    ):
        sub_category = (
            SubCategoryRepository.get_by_id(
                db,
                sub_category_id,
            )
        )

        if sub_category is None:
            return None

        return SubCategoryRepository.update_status(
            db,
            sub_category,
            data.status,
        )