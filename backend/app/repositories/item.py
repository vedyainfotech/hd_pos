
from sqlalchemy import func, select
from sqlalchemy.orm import Session, selectinload

from app.models.item import (
    FoodDetail,
    ItemSubCategoryMapping,
)


class ItemRepository:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
        category_id: int | None = None,
        sub_category_id: int | None = None,
        search: str | None = None,
    ) -> list[FoodDetail]:
        query = select(FoodDetail).options(
            selectinload(FoodDetail.sub_categories)
        )

        if not include_inactive:
            query = query.where(FoodDetail.status.is_(True))

        if category_id is not None:
            query = query.where(
                FoodDetail.category_id == category_id
            )

        if sub_category_id is not None:
            query = query.where(
                FoodDetail.sub_categories.any(
                    ItemSubCategoryMapping.sub_category_id
                    == sub_category_id
                )
            )

        if search and search.strip():
            query = query.where(
                FoodDetail.item_name.ilike(
                    f"%{search.strip()}%"
                )
            )

        query = query.order_by(FoodDetail.id)

        return list(db.scalars(query).all())

    @staticmethod
    def get_by_id(
        db: Session,
        item_id: int,
    ) -> FoodDetail | None:
        query = (
            select(FoodDetail)
            .options(
                selectinload(FoodDetail.sub_categories)
            )
            .where(FoodDetail.id == item_id)
        )

        return db.scalar(query)

    @staticmethod
    def get_by_name(
        db: Session,
        category_id: int,
        name: str,
        exclude_id: int | None = None,
    ) -> FoodDetail | None:
        normalized_input = func.lower(
            func.regexp_replace(
                name,
                r"\s+",
                "",
                "g",
            )
        )

        normalized_column = func.lower(
            func.regexp_replace(
                FoodDetail.item_name,
                r"\s+",
                "",
                "g",
            )
        )

        query = select(FoodDetail).where(
            FoodDetail.category_id == category_id,
            normalized_column == normalized_input,
        )

        if exclude_id is not None:
            query = query.where(
                FoodDetail.id != exclude_id
            )

        return db.scalar(query)

    @staticmethod
    def create(
        db: Session,
        item: FoodDetail,
    ) -> FoodDetail:
        db.add(item)
        db.flush()
        return item

    @staticmethod
    def update(
        db: Session,
        item: FoodDetail,
    ) -> FoodDetail:
        db.flush()
        return item

    @staticmethod
    def update_status(
        db: Session,
        item: FoodDetail,
        status: bool,
    ) -> FoodDetail:
        item.status = status
        db.flush()
        return item

    @staticmethod
    def get_mapping(
        db: Session,
        item_id: int,
        sub_category_id: int,
    ) -> ItemSubCategoryMapping | None:
        query = select(ItemSubCategoryMapping).where(
            ItemSubCategoryMapping.item_id == item_id,
            ItemSubCategoryMapping.sub_category_id
            == sub_category_id,
        )

        return db.scalar(query)

    @staticmethod
    def get_mappings(
        db: Session,
        item_id: int,
    ) -> list[ItemSubCategoryMapping]:
        query = (
            select(ItemSubCategoryMapping)
            .where(ItemSubCategoryMapping.item_id == item_id)
            .order_by(ItemSubCategoryMapping.id)
        )

        return list(db.scalars(query).all())

    @staticmethod
    def create_mapping(
        db: Session,
        mapping: ItemSubCategoryMapping,
    ) -> ItemSubCategoryMapping:
        db.add(mapping)
        db.flush()
        return mapping

    @staticmethod
    def delete_mapping(
        db: Session,
        mapping: ItemSubCategoryMapping,
    ) -> None:
        db.delete(mapping)
        db.flush()
