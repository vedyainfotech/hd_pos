
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.category import Category
from app.models.sub_category import SubCategory
from app.models.item import (
    FoodDetail,
    ItemSubCategoryMapping,
    FoodDetailLog,
)
from app.repositories.item import ItemRepository
from app.schemas.item import (
    ItemCreate,
    ItemStatusUpdate,
    ItemUpdate,
)


class ItemService:

    # ---------------------------------------------------------
    # READ ITEMS
    # ---------------------------------------------------------

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
    def get_item(db: Session, item_id: int):
        return ItemRepository.get_by_id(db, item_id)

    # ---------------------------------------------------------
    # VALIDATE CATEGORY
    # ---------------------------------------------------------

    @staticmethod
    def _validate_category(
        db: Session,
        category_id: int,
    ) -> Category:
        category = db.get(Category, category_id)

        if category is None:
            raise ValueError("Category not found")

        return category

    # ---------------------------------------------------------
    # VALIDATE SUBCATEGORIES
    # ---------------------------------------------------------

    @staticmethod
    def _validate_subcategories(
        db: Session,
        category_id: int,
        entries,
        *,
        allow_same_as: bool = True,
        require_active: bool = False,
    ):
        validated = []
        seen_ids = set()

        for entry in entries:
            subcategory_id = entry.sub_category_id

            if subcategory_id in seen_ids:
                raise ValueError(
                    f"Subcategory {subcategory_id} was selected more than once"
                )

            seen_ids.add(subcategory_id)

            subcategory = db.get(SubCategory, subcategory_id)

            if subcategory is None:
                raise ValueError(
                    f"Subcategory {subcategory_id} not found"
                )

            if subcategory.category_id != category_id:
                raise ValueError(
                    f"Subcategory '{subcategory.name}' does not belong "
                    "to the selected category"
                )

            if require_active and not subcategory.status:
                raise ValueError(
                    f"Inactive subcategory '{subcategory.name}' "
                    "cannot be assigned to a new item"
                )

            same_as = entry.same_as_sub_category

            if same_as and not allow_same_as:
                raise ValueError(
                    "Same as subcategory is not allowed for this request"
                )

            price = (
                Decimal(str(subcategory.price))
                if same_as
                else Decimal(str(entry.price))
            )

            if price < 0:
                raise ValueError("Price cannot be negative")

            validated.append(
                {
                    "subcategory": subcategory,
                    "price": price,
                    "same_as_sub_category": same_as,
                    "status": getattr(entry, "status", True),
                }
            )

        if len(validated) > 1 and any(
            entry["same_as_sub_category"] for entry in validated
        ):
            raise ValueError(
                "Same as subcategory can only be enabled when "
                "exactly one subcategory is selected"
            )

        return validated

    # ---------------------------------------------------------
    # FIND OR CREATE MASTER ITEM
    # ---------------------------------------------------------

    @staticmethod
    def _find_or_create_item(
        db: Session,
        category_id: int,
        item_name: str,
        status: bool,
    ) -> FoodDetail:
        item = ItemRepository.get_by_name(
            db=db,
            category_id=category_id,
            name=item_name,
        )

        if item is not None:
            return item

        item = FoodDetail(
            category_id=category_id,
            item_name=item_name.strip(),
            status=status,
        )

        return ItemRepository.create(db, item)

    # ---------------------------------------------------------
    # ADD OR UPDATE SUBCATEGORY MAPPINGS
    # Existing mappings are preserved.
    # ---------------------------------------------------------

    @staticmethod
    def _upsert_mappings(
        db: Session,
        item: FoodDetail,
        validated_entries,
    ) -> None:
        existing_mappings = {
            mapping.sub_category_id: mapping
            for mapping in ItemRepository.get_mappings(db, item.id)
        }

        requested_ids = {
            entry["subcategory"].id
            for entry in validated_entries
        }

        # A "same as subcategory" selection is only valid when
        # the item has exactly one mapping after this operation.
        resulting_ids = set(existing_mappings) | requested_ids

        if len(resulting_ids) > 1 and any(
            entry["same_as_sub_category"]
            for entry in validated_entries
        ):
            raise ValueError(
                "Same as subcategory can only be enabled when "
                "the item has exactly one assigned subcategory"
            )

        for entry in validated_entries:
            subcategory = entry["subcategory"]
            mapping = existing_mappings.get(subcategory.id)

            if mapping is None:
                if not subcategory.status:
                    raise ValueError(
                        f"Inactive subcategory '{subcategory.name}' "
                        "cannot be newly assigned"
                    )

                mapping = ItemSubCategoryMapping(
                    item_id=item.id,
                    sub_category_id=subcategory.id,
                    price=entry["price"],
                    same_as_sub_category=(
                        entry["same_as_sub_category"]
                    ),
                    status=entry["status"],
                )

                ItemRepository.create_mapping(db, mapping)
                continue

            new_price = entry["price"]

            if mapping.price != new_price:
                db.add(
                    FoodDetailLog(
                        fd_id=item.id,
                        sub_category_id=subcategory.id,
                        old_price=mapping.price,
                        new_price=new_price,
                    )
                )

                mapping.price = new_price

            mapping.same_as_sub_category = (
                entry["same_as_sub_category"]
            )
            mapping.status = entry["status"]

        # Intentionally do not delete mappings omitted from the request.
        # Existing assignments remain unless a dedicated removal feature
        # is implemented later.

    # ---------------------------------------------------------
    # CREATE ITEM
    # If the same name/category already exists, reuse that master
    # item and add or update its requested mappings.
    # ---------------------------------------------------------

    @staticmethod
    def create_item(
        db: Session,
        data: ItemCreate,
    ):
        try:
            ItemService._validate_category(
                db,
                data.category_id,
            )

            validated = ItemService._validate_subcategories(
                db,
                data.category_id,
                data.sub_categories,
                require_active=True,
            )

            item = ItemRepository.get_by_name(
                db=db,
                category_id=data.category_id,
                name=data.item_name,
            )

            # Reject an already-existing item/subcategory pair.
            if item is not None:
                existing_mappings = {
                    mapping.sub_category_id
                    for mapping in ItemRepository.get_mappings(
                        db,
                        item.id,
                    )
                }

                for entry in validated:
                    subcategory = entry["subcategory"]

                    if subcategory.id in existing_mappings:
                        raise ValueError(
                            "Already there is item with the same "
                            "name and sub-category"
                        )

                # The item exists, but the selected subcategory
                # is new: add its mapping without duplicating the item.
                ItemService._upsert_mappings(
                    db,
                    item,
                    validated,
                )
            else:
                item = FoodDetail(
                    category_id=data.category_id,
                    item_name=data.item_name.strip(),
                    status=data.status,
                )

                ItemRepository.create(db, item)

                ItemService._upsert_mappings(
                    db,
                    item,
                    validated,
                )

            db.commit()

            return ItemRepository.get_by_id(db, item.id)

        except Exception:
            db.rollback()
            raise

    # ---------------------------------------------------------
    # UPDATE ITEM
    # Only mappings supplied in the request are added or updated.
    # Other existing mappings are preserved.
    # ---------------------------------------------------------

    @staticmethod
    def update_item(
        db: Session,
        item_id: int,
        data: ItemUpdate,
    ):
        item = ItemRepository.get_by_id(db, item_id)

        if item is None:
            return None

        try:
            ItemService._validate_category(
                db,
                data.category_id,
            )

            validated = ItemService._validate_subcategories(
                db,
                data.category_id,
                data.sub_categories,
            )

            duplicate = ItemRepository.get_by_name(
                db=db,
                category_id=data.category_id,
                name=data.item_name,
                exclude_id=item_id,
            )

            if duplicate is not None:
                raise ValueError(
                    "An item with this name already exists in this category"
                )

            item.category_id = data.category_id
            item.item_name = data.item_name.strip()
            item.status = data.status

            ItemService._upsert_mappings(
                db,
                item,
                validated,
            )

            db.commit()

            return ItemRepository.get_by_id(db, item_id)

        except Exception:
            db.rollback()
            raise

    # ---------------------------------------------------------
    # UPDATE ITEM STATUS
    # ---------------------------------------------------------

    @staticmethod
    def update_status(
        db: Session,
        item_id: int,
        data: ItemStatusUpdate,
    ):
        item = ItemRepository.get_by_id(db, item_id)

        if item is None:
            return None

        try:
            ItemRepository.update_status(
                db,
                item,
                data.status,
            )

            db.commit()

            return ItemRepository.get_by_id(db, item_id)

        except Exception:
            db.rollback()
            raise
