
from datetime import date

from sqlalchemy.orm import Session, selectinload

from app.models.order_selection import OrderSelectionAssignment
from app.models.menu_schedule import MenuSchedule, MenuScheduleItem
from app.models.hd_items import HDItem
from app.models.customer import Customer
from app.models.customer_address import CustomerAddress
from app.models.category import Category
from app.models.sub_category import SubCategory


class OrderSelectionRepository:

    def __init__(self, db: Session):
        self.db = db

    # Get pending assignments for a delivery date
    def get_pending_assignments(self, delivery_date: date):
        return (
            self.db.query(OrderSelectionAssignment)
            .filter(
                OrderSelectionAssignment.delivery_date == delivery_date,
                OrderSelectionAssignment.selected_item_id.is_(None),
                OrderSelectionAssignment.is_active.is_(True),
            )
            .order_by(OrderSelectionAssignment.id)
            .all()
        )

    # Get assignment by ID
    def get_assignment_by_id(self, assignment_id: int):
        return (
            self.db.query(OrderSelectionAssignment)
            .filter(
                OrderSelectionAssignment.id == assignment_id
            )
            .first()
        )

    # Create a pending assignment
    def create_assignment(self, assignment: dict):
        db_assignment = OrderSelectionAssignment(**assignment)

        self.db.add(db_assignment)
        self.db.commit()
        self.db.refresh(db_assignment)

        return db_assignment

    # Get customer with phone numbers and addresses
    def get_customer(self, customer_id: int):
        return (
            self.db.query(Customer)
            .options(
                selectinload(Customer.phone_numbers),
                selectinload(Customer.addresses),
            )
            .filter(Customer.id == customer_id)
            .first()
        )

    # Get customer address
    def get_address(self, address_id: int):
        return (
            self.db.query(CustomerAddress)
            .filter(CustomerAddress.id == address_id)
            .first()
        )

    # Get category
    def get_category(self, category_id: int):
        return (
            self.db.query(Category)
            .filter(Category.id == category_id)
            .first()
        )

    # Get subcategory
    def get_subcategory(self, sub_category_id: int):
        return (
            self.db.query(SubCategory)
            .filter(SubCategory.id == sub_category_id)
            .first()
        )

    # Get active subcategories for a category
    def get_subcategories(self, category_id: int):
        return (
            self.db.query(SubCategory)
            .filter(
                SubCategory.category_id == category_id,
                SubCategory.status.is_(True),
            )
            .order_by(SubCategory.name)
            .all()
        )

    # Get items scheduled for a particular date, category and subcategory
    def get_available_items(
        self,
        delivery_date: date,
        category_id: int,
        sub_category_id: int,
    ):
        return (
            self.db.query(HDItem)
            .join(
                MenuScheduleItem,
                MenuScheduleItem.item_id == HDItem.id,
            )
            .join(
                MenuSchedule,
                MenuSchedule.id == MenuScheduleItem.schedule_id,
            )
            .filter(
                MenuSchedule.delivery_date == delivery_date,
                MenuSchedule.category_id == category_id,
                HDItem.category_id == category_id,
                HDItem.sub_category_id == sub_category_id,
                HDItem.status.is_(True),
            )
            .order_by(HDItem.name)
            .all()
        )

    # Save operator's selected item
    def resolve_assignment(
        self,
        assignment: OrderSelectionAssignment,
        selected_sub_category_id: int,
        selected_item_id: int,
    ):
        assignment.selected_sub_category_id = selected_sub_category_id
        assignment.selected_item_id = selected_item_id

        self.db.commit()
        self.db.refresh(assignment)

        return assignment
