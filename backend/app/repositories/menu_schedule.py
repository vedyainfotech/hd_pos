from datetime import date

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.models.menu_schedule import MenuSchedule, MenuScheduleItem
from app.models.category import Category
from app.models.sub_category import SubCategory
from app.models.hd_items import HDItem


# ---------------------------------
# Get Schedule by Date and Category
# ---------------------------------

def get_schedule_by_date_category(
    db: Session,
    delivery_date: date,
    category_id: int,
):
    statement = select(MenuSchedule).where(
        MenuSchedule.delivery_date == delivery_date,
        MenuSchedule.category_id == category_id,
    )

    return db.scalar(statement)


# ---------------------------------
# Get All Schedules for a Date
# ---------------------------------

def get_schedules_by_date(
    db: Session,
    delivery_date: date,
):
    statement = (
        select(MenuSchedule)
        .where(MenuSchedule.delivery_date == delivery_date)
        .order_by(MenuSchedule.category_id)
    )

    return db.scalars(statement).all()


# ---------------------------------
# Get Schedule Items
# ---------------------------------

def get_schedule_items(
    db: Session,
    schedule_id: int,
):
    statement = (
        select(
            MenuScheduleItem.id.label("schedule_item_id"),
            HDItem.id.label("item_id"),
            HDItem.name.label("item_name"),
            HDItem.price.label("price"),
            HDItem.sub_category_id.label("sub_category_id"),
            SubCategory.name.label("sub_category_name"),
        )
        .join(
            HDItem,
            MenuScheduleItem.item_id == HDItem.id,
        )
        .outerjoin(
            SubCategory,
            HDItem.sub_category_id == SubCategory.id,
        )
        .where(
            MenuScheduleItem.schedule_id == schedule_id
        )
        .order_by(
            HDItem.sub_category_id,
            HDItem.name,
        )
    )

    return db.execute(statement).all()


# ---------------------------------
# Get Active Category
# ---------------------------------

def get_active_category(
    db: Session,
    category_id: int,
):
    statement = select(Category).where(
        Category.id == category_id,
        Category.status.is_(True),
    )

    return db.scalar(statement)


# ---------------------------------
# Get Active Subcategories
# ---------------------------------

def get_active_subcategories(
    db: Session,
    category_id: int,
):
    statement = (
        select(SubCategory)
        .where(
            SubCategory.category_id == category_id,
            SubCategory.status.is_(True),
        )
        .order_by(SubCategory.id)
    )

    return db.scalars(statement).all()


# ---------------------------------
# Get Available HD Items
# ---------------------------------

def get_available_items(
    db: Session,
    category_id: int,
    sub_category_id: int | None = None,
    search: str | None = None,
):
    statement = select(HDItem).where(
        HDItem.category_id == category_id,
        HDItem.status.is_(True),
    )

    if sub_category_id is not None:
        statement = statement.where(
            HDItem.sub_category_id == sub_category_id
        )

    if search:
        statement = statement.where(
            HDItem.name.ilike(f"%{search.strip()}%")
        )

    statement = statement.order_by(HDItem.name)

    return db.scalars(statement).all()


# ---------------------------------
# Get HD Items by IDs
# ---------------------------------

def get_items_by_ids(
    db: Session,
    item_ids: list[int],
):
    if not item_ids:
        return []

    statement = select(HDItem).where(
        HDItem.id.in_(item_ids)
    )

    return db.scalars(statement).all()


# ---------------------------------
# Create Schedule
# ---------------------------------

def create_schedule(
    db: Session,
    delivery_date: date,
    category_id: int,
):
    schedule = MenuSchedule(
        delivery_date=delivery_date,
        category_id=category_id,
    )

    db.add(schedule)
    db.flush()

    return schedule


# ---------------------------------
# Delete Existing Schedule Items
# ---------------------------------

def delete_schedule_items(
    db: Session,
    schedule_id: int,
):
    # Use a direct SQL DELETE instead of marking ORM objects as deleted.
    # This ensures rows are removed from PostgreSQL before replacement
    # MenuScheduleItem rows with the same (schedule_id, item_id) are inserted.
    statement = delete(MenuScheduleItem).where(
        MenuScheduleItem.schedule_id == schedule_id
    )

    db.execute(
        statement.execution_options(synchronize_session=False)
    )


# ---------------------------------
# Add Schedule Items
# ---------------------------------

def add_schedule_items(
    db: Session,
    schedule_id: int,
    item_ids: list[int],
):
    schedule_items = [
        MenuScheduleItem(
            schedule_id=schedule_id,
            item_id=item_id,
        )
        for item_id in item_ids
    ]

    db.add_all(schedule_items)


# ---------------------------------
# Delete Empty Schedule
# ---------------------------------

def delete_schedule(
    db: Session,
    schedule: MenuSchedule,
):
    db.delete(schedule)
