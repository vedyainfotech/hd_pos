from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.sub_category import SubCategory


class SubCategoryRepository:

    # ============================================================
    # GET ALL
    # ============================================================

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
        category_id: int | None = None,
        search: str | None = None,
    ) -> list[SubCategory]:

        query = select(SubCategory)

        # Only active records by default
        if not include_inactive:
            query = query.where(
                SubCategory.status.is_(True)
            )

        # Filter by parent category
        if category_id is not None:
            query = query.where(
                SubCategory.category_id == category_id
            )

        # Search
        if search:
            search_value = search.strip()

            if search_value:
                query = query.where(
                    SubCategory.name.ilike(
                        f"%{search_value}%"
                    )
                )

        query = query.order_by(
            SubCategory.id
        )

        return list(
            db.scalars(query).all()
        )

    # ============================================================
    # GET BY ID
    # ============================================================

    @staticmethod
    def get_by_id(
        db: Session,
        sub_category_id: int,
    ) -> SubCategory | None:

        query = select(SubCategory).where(
            SubCategory.id == sub_category_id
        )

        return db.scalar(query)

    # ============================================================
    # GET BY NORMALIZED NAME
    # ============================================================

    @staticmethod
    def get_by_name(
        db: Session,
        category_id: int,
        name: str,
        exclude_id: int | None = None,
    ) -> SubCategory | None:

        # Normalize input:
        #
        # " Biryani "
        # "BIRYANI"
        # "bir y a n i"
        #
        # become comparable values.

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
                func.trim(SubCategory.name),
                r"\s+",
                "",
                "g",
            )
        )

        query = select(SubCategory).where(
            SubCategory.category_id == category_id,
            normalized_column == normalized_input,
        )

        # During update, don't compare the record with itself.
        if exclude_id is not None:
            query = query.where(
                SubCategory.id != exclude_id
            )

        return db.scalar(query)

    # ============================================================
    # CREATE
    # ============================================================

    @staticmethod
    def create(
        db: Session,
        sub_category: SubCategory,
    ) -> SubCategory:

        db.add(sub_category)

        db.commit()

        db.refresh(sub_category)

        return sub_category

    # ============================================================
    # UPDATE
    # ============================================================

    @staticmethod
    def update(
        db: Session,
        sub_category: SubCategory,
    ) -> SubCategory:

        db.commit()

        db.refresh(sub_category)

        return sub_category

    # ============================================================
    # UPDATE STATUS
    # ============================================================

    @staticmethod
    def update_status(
        db: Session,
        sub_category: SubCategory,
        status: bool,
    ) -> SubCategory:

        sub_category.status = status

        db.commit()

        db.refresh(sub_category)

        return sub_category