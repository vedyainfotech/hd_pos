from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.category import Category


class CategoryRepository:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
    ) -> list[Category]:
        query = select(Category)

        if not include_inactive:
            query = query.where(
                Category.status.is_(True)
            )

        query = query.order_by(Category.id)

        return list(
            db.scalars(query).all()
        )

    @staticmethod
    def get_by_id(
        db: Session,
        category_id: int,
    ) -> Category | None:
        query = select(Category).where(
            Category.id == category_id
        )

        return db.scalar(query)

    @staticmethod
    def get_by_name(
        db: Session,
        name: str,
        exclude_id: int | None = None,
    ) -> Category | None:

        normalized_input = func.lower(
            func.regexp_replace(
                func.trim(name),
                r'\s+',
                '',
                'g',
            )
        )

        normalized_column = func.lower(
            func.regexp_replace(
                func.trim(Category.name),
                r'\s+',
                '',
                'g',
            )
        )

        query = select(Category).where(
            normalized_column == normalized_input
        )

        if exclude_id is not None:
            query = query.where(
                Category.id != exclude_id
            )

        return db.scalar(query)

    @staticmethod
    def create(
        db: Session,
        category: Category,
    ) -> Category:
        db.add(category)
        db.commit()
        db.refresh(category)

        return category

    @staticmethod
    def update(
        db: Session,
        category: Category,
    ) -> Category:
        db.commit()
        db.refresh(category)

        return category

    @staticmethod
    def update_status(
        db: Session,
        category: Category,
        status: bool,
    ) -> Category:
        category.status = status

        db.commit()
        db.refresh(category)

        return category