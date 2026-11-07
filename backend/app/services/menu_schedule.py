from datetime import date

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.category import Category
from app.repositories import menu_schedule as repository


# ---------------------------------
# Get Available Menu Items
# ---------------------------------

def get_available_menu(
    db: Session,
    category_id: int,
    search: str | None = None,
):
    category = repository.get_active_category(
        db,
        category_id,
    )

    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found or inactive",
        )

    subcategories = repository.get_active_subcategories(
        db,
        category_id,
    )

    result = []

    for subcategory in subcategories:
        items = repository.get_available_items(
            db=db,
            category_id=category_id,
            sub_category_id=subcategory.id,
            search=search,
        )

        result.append({
            "id": subcategory.id,
            "name": subcategory.name,
            "items": [
                {
                    "id": item.id,
                    "name": item.name,
                    "price": item.price,
                    "category_id": item.category_id,
                    "sub_category_id": item.sub_category_id,
                    "sub_category_name": subcategory.name,
                }
                for item in items
            ],
        })

    return {
        "category_id": category.id,
        "category_name": category.name,
        "sub_categories": result,
    }


# ---------------------------------
# Validate Selected Items
# ---------------------------------

def validate_selected_items(
    db: Session,
    category_id: int,
    item_ids: list[int],
):
    if len(item_ids) != len(set(item_ids)):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Duplicate items are not allowed",
        )

    if not item_ids:
        return []

    items = repository.get_items_by_ids(
        db,
        item_ids,
    )

    if len(items) != len(item_ids):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="One or more selected items do not exist",
        )

    subcategories = repository.get_active_subcategories(
        db,
        category_id,
    )

    active_subcategory_ids = {
        subcategory.id
        for subcategory in subcategories
    }

    for item in items:
        if not item.status:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Item '{item.name}' is inactive",
            )

        if item.category_id != category_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Item '{item.name}' does not belong "
                    "to the selected category"
                ),
            )

        if item.sub_category_id not in active_subcategory_ids:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Item '{item.name}' does not belong "
                    "to an active subcategory"
                ),
            )

    return items


# ---------------------------------
# Save or Update Menu Schedule
# ---------------------------------

def save_menu_schedule(
    db: Session,
    delivery_date: date,
    category_id: int,
    item_ids: list[int],
):
    category = repository.get_active_category(
        db,
        category_id,
    )

    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found or inactive",
        )

    # Validate all selected items before changing the schedule.
    validate_selected_items(
        db,
        category_id,
        item_ids,
    )

    try:
        schedule = repository.get_schedule_by_date_category(
            db,
            delivery_date,
            category_id,
        )

        # No selected items: remove an existing schedule.
        if not item_ids:
            if schedule:
                repository.delete_schedule_items(
                    db,
                    schedule.id,
                )
                # Ensure child rows are deleted before deleting the schedule.
                db.flush()
                repository.delete_schedule(
                    db,
                    schedule,
                )

            db.commit()

            return {
                "message": "Menu schedule cleared successfully",
                "delivery_date": delivery_date,
                "category_id": category_id,
            }

        # Create a new schedule when one doesn't exist.
        if not schedule:
            schedule = repository.create_schedule(
                db,
                delivery_date,
                category_id,
            )

        # Replace the previous item selection.
        # The repository performs a direct SQL DELETE. Flush it before
        # inserting replacement rows to avoid uq_menu_schedule_item conflicts.
        repository.delete_schedule_items(
            db,
            schedule.id,
        )
        db.flush()

        repository.add_schedule_items(
            db,
            schedule.id,
            item_ids,
        )

        db.commit()
        db.refresh(schedule)

        return {
            "message": "Menu schedule saved successfully",
            "schedule_id": schedule.id,
            "delivery_date": schedule.delivery_date,
            "category_id": schedule.category_id,
        }

    except Exception:
        db.rollback()
        raise


# ---------------------------------
# Get Scheduled Menu for a Date
# ---------------------------------

def get_menu_by_date(
    db: Session,
    delivery_date: date,
):
    schedules = repository.get_schedules_by_date(
        db,
        delivery_date,
    )

    result = []

    for schedule in schedules:
        category = db.get(
            Category,
            schedule.category_id,
        )

        if not category:
            continue

        scheduled_items = repository.get_schedule_items(
            db,
            schedule.id,
        )

        items = []

        for item in scheduled_items:
            items.append({
                "id": item.schedule_item_id,
                "item_id": item.item_id,
                "item_name": item.item_name,
                "price": float(item.price),
                "sub_category_id": item.sub_category_id,
                "sub_category_name": item.sub_category_name,
            })

        result.append({
            "id": schedule.id,
            "delivery_date": schedule.delivery_date,
            "category_id": schedule.category_id,
            "category_name": category.name,
            "items": items,
        })

    return {
        "delivery_date": delivery_date,
        "schedules": result,
    }
