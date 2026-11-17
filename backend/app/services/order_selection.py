
from datetime import date

from sqlalchemy.orm import Session

from app.repositories.order_selection import OrderSelectionRepository


class OrderSelectionService:

    def __init__(self, db: Session):
        self.repository = OrderSelectionRepository(db)

    # Get pending assignments that have multiple available daily menu items
    def get_pending_assignments(self, delivery_date: date):
        assignments = self.repository.get_pending_assignments(delivery_date)

        results = []

        for assignment in assignments:
            items = self.repository.get_available_items(
                delivery_date=assignment.delivery_date,
                category_id=assignment.category_id,
                sub_category_id=assignment.sub_category_id,
            )

            # Only assignments with multiple choices need operator selection
            if len(items) <= 1:
                continue

            category = self.repository.get_category(assignment.category_id)
            subcategory = self.repository.get_subcategory(
                assignment.sub_category_id
            )

            if category is None or subcategory is None:
                continue

            results.append({
                "id": assignment.id,
                "customer_id": assignment.customer_id,
                "address_id": assignment.address_id,
                "delivery_date": assignment.delivery_date,
                "meal_category": category.name,
                "sub_category": subcategory.name,
                "quantity": assignment.quantity,
            })

        return results

    # Get customer details and addresses
    def get_customer(self, customer_id: int):
        customer = self.repository.get_customer(customer_id)

        if customer is None:
            raise ValueError("Customer not found")

        phone_numbers = customer.phone_numbers or []

        # Use the customer's first saved phone number.
        # If unavailable, use the first address contact number.
        mobile_number = (
            phone_numbers[0].phone_number
            if phone_numbers
            else (
                customer.addresses[0].contact_number
                if customer.addresses
                else ""
            )
        )

        addresses = []

        for address in customer.addresses:
            parts = [
                address.house_flat_number,
                address.house_name,
                address.street,
                address.area,
                address.landmark,
                address.district,
                address.state,
                address.pincode,
                address.country,
            ]

            full_address = ", ".join(
                str(part) for part in parts if part
            )

            addresses.append({
                "id": address.id,
                "label": address.address_type,
                "address": full_address,
                "is_default": False,
            })

        return {
            "id": customer.id,
            "name": customer.name,
            "mobile_number": mobile_number,
            "addresses": addresses,
            "status": True,
        }

    # Get available subcategories for an assignment
    def get_subcategories(self, assignment_id: int):
        assignment = self.repository.get_assignment_by_id(assignment_id)

        if assignment is None or not assignment.is_active:
            raise ValueError("Assignment not found")

        subcategories = self.repository.get_subcategories(
            assignment.category_id
        )

        return [
            {
                "id": subcategory.id,
                "name": subcategory.name,
            }
            for subcategory in subcategories
        ]

    # Get available daily menu items
    def get_available_items(
        self,
        assignment_id: int,
        sub_category_id: int,
    ):
        assignment = self.repository.get_assignment_by_id(assignment_id)

        if assignment is None or not assignment.is_active:
            raise ValueError("Assignment not found")

        subcategory = self.repository.get_subcategory(sub_category_id)

        if (
            subcategory is None
            or subcategory.category_id != assignment.category_id
        ):
            raise ValueError("Invalid subcategory")

        items = self.repository.get_available_items(
            delivery_date=assignment.delivery_date,
            category_id=assignment.category_id,
            sub_category_id=sub_category_id,
        )

        category = self.repository.get_category(assignment.category_id)

        if category is None:
            raise ValueError("Category not found")

        return [
            {
                "id": item.id,
                "name": item.name,
                "category": category.name,
                "sub_category": subcategory.name,
                "price": item.price,
                "status": item.status,
            }
            for item in items
        ]

    # Save the operator's selected item
    def resolve_assignment(
        self,
        assignment_id: int,
        selected_sub_category_id: int,
        selected_item_id: int,
    ):
        assignment = self.repository.get_assignment_by_id(assignment_id)

        if assignment is None or not assignment.is_active:
            raise ValueError("Assignment not found")

        if assignment.selected_item_id is not None:
            raise ValueError("Assignment has already been resolved")

        subcategory = self.repository.get_subcategory(
            selected_sub_category_id
        )

        if (
            subcategory is None
            or subcategory.category_id != assignment.category_id
        ):
            raise ValueError("Invalid subcategory")

        available_items = self.repository.get_available_items(
            delivery_date=assignment.delivery_date,
            category_id=assignment.category_id,
            sub_category_id=selected_sub_category_id,
        )

        selected_item = next(
            (
                item
                for item in available_items
                if item.id == selected_item_id
            ),
            None,
        )

        if selected_item is None:
            raise ValueError(
                "Selected item is not available in the daily menu"
            )

        return self.repository.resolve_assignment(
            assignment=assignment,
            selected_sub_category_id=selected_sub_category_id,
            selected_item_id=selected_item_id,
        )

    # Create a pending assignment
    def create_assignment(self, data: dict):
        customer = self.repository.get_customer(data["customer_id"])

        if customer is None:
            raise ValueError("Customer not found")

        address = self.repository.get_address(data["address_id"])

        if (
            address is None
            or address.customer_id != data["customer_id"]
        ):
            raise ValueError("Invalid customer address")

        category = self.repository.get_category(data["category_id"])

        if category is None:
            raise ValueError("Category not found")

        subcategory = self.repository.get_subcategory(
            data["sub_category_id"]
        )

        if (
            subcategory is None
            or subcategory.category_id != data["category_id"]
        ):
            raise ValueError("Invalid subcategory")

        return self.repository.create_assignment(data)
