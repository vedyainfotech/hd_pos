from sqlalchemy.orm import Session

from app.models.item import Item
from app.models.category import Category
from app.models.sub_category import SubCategory
from app.repositories.item import ItemRepository
from app.schemas.item import (
    ItemCreate,
    ItemStatusUpdate,
    ItemUpdate,
)


class ItemService:

    @staticmethod
    def get_items(
        db: Session,
        include_inactive: bool = False,
        category_id: int | None = None,
        sub_category_id: int | None = None,
        search: str | None = None,
    ):
        return ItemRepository.get_all(
            db=db,
            include_inactive=include_inactive,
            category_id=category_id,
            sub_category_id=sub_category_id,
            search=search,
        )

    @staticmethod
    def get_item(
        db: Session,
        item_id: int,
    ):
        return ItemRepository.get_by_id(
            db,
            item_id,
        )

    @staticmethod
    def create_item(
        db: Session,
        data: ItemCreate,
    ):
        # Check category
        category = db.get(
            Category,
            data.category_id,
        )

        if category is None:
            raise ValueError(
                "Category not found"
            )

        # Check sub category
        sub_category = db.get(
            SubCategory,
            data.sub_category_id,
        )

        if sub_category is None:
            raise ValueError(
                "Sub category not found"
            )

        # Make sure sub category belongs
        # to the selected category.
        if sub_category.category_id != data.category_id:
            raise ValueError(
                "Sub category does not belong to the selected category"
            )

        # Prevent duplicate item names
        # inside the same sub category.
        existing = ItemRepository.get_by_name(
            db=db,
            sub_category_id=data.sub_category_id,
            name=data.name,
        )

        if existing is not None:
            raise ValueError(
                "Item already exists under this sub category"
            )

        # If Same As Category is selected,
        # use the sub category price.
        item_price = data.price

        if data.same_as_category:
            item_price = sub_category.price

        item = Item(
            category_id=data.category_id,
            sub_category_id=data.sub_category_id,
            name=data.name.strip(),
            price=item_price,
            same_as_category=data.same_as_category,
        )

        return ItemRepository.create(
            db,
            item,
        )

    @staticmethod
    def update_item(
        db: Session,
        item_id: int,
        data: ItemUpdate,
    ):
        item = ItemRepository.get_by_id(
            db,
            item_id,
        )

        if item is None:
            return None

        # Check category
        category = db.get(
            Category,
            data.category_id,
        )

        if category is None:
            raise ValueError(
                "Category not found"
            )

        # Check sub category
        sub_category = db.get(
            SubCategory,
            data.sub_category_id,
        )

        if sub_category is None:
            raise ValueError(
                "Sub category not found"
            )

        # Validate category → subcategory relationship
        if sub_category.category_id != data.category_id:
            raise ValueError(
                "Sub category does not belong to the selected category"
            )

        # Prevent duplicate names
        existing = ItemRepository.get_by_name(
            db=db,
            sub_category_id=data.sub_category_id,
            name=data.name,
            exclude_id=item_id,
        )

        if existing is not None:
            raise ValueError(
                "Item already exists under this sub category"
            )

        # Determine price
        item_price = data.price

        if data.same_as_category:
            item_price = sub_category.price

        item.category_id = data.category_id
        item.sub_category_id = data.sub_category_id
        item.name = data.name.strip()
        item.price = item_price
        item.same_as_category = data.same_as_category
        item.status = data.status

        return ItemRepository.update(
            db,
            item,
        )

    @staticmethod
    def update_status(
        db: Session,
        item_id: int,
        data: ItemStatusUpdate,
    ):
        item = ItemRepository.get_by_id(
            db,
            item_id,
        )

        if item is None:
            return None

        return ItemRepository.update_status(
            db,
            item,
            data.status,
        )