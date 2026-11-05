
from uuid import uuid4

from fastapi import HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.repositories.customer import CustomerRepository
from app.schemas.customer import (
    CustomerCreate,
    CustomerUpdate,
    CustomerResponse,
)


class CustomerService:

    @staticmethod
    def _format_customer(customer):
        """Convert database customer data into Flutter-compatible response."""

        return CustomerResponse(
            id=str(customer.id),
            customer_code=customer.customer_code,
            name=customer.name,
            phone_numbers=[
                phone.phone_number
                for phone in customer.phone_numbers
            ],
            email=customer.email,
            addresses=[
                {
                    "id": str(address.id),
                    "address_code": address.address_code,
                    "contact_name": address.contact_name,
                    "contact_number": address.contact_number,
                    "house_name": address.house_name,
                    "house_flat_number": address.house_flat_number,
                    "address_type": address.address_type,
                    "country": address.country,
                    "state": address.state,
                    "district": address.district,
                    "area": address.area,
                    "street": address.street,
                    "landmark": address.landmark,
                    "pincode": address.pincode,
                    "location_link": address.location_link,
                    "monthly_food_order": address.monthly_food_order,
                }
                for address in customer.addresses
            ],
        )

    @staticmethod
    def create_customer(
        db: Session,
        customer_data: CustomerCreate,
    ):

        data = customer_data.model_dump()

        data["customer_code"] = (
            f"CUST-{uuid4().hex[:10].upper()}"
        )

        try:
            customer = CustomerRepository.create(db, data)

            return CustomerService._format_customer(customer)

        except ValueError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(exc),
            )

        except IntegrityError:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Duplicate customer data is not allowed.",
            )

    @staticmethod
    def get_customer(
        db: Session,
        customer_id: int,
    ):

        customer = CustomerRepository.get_by_id(
            db,
            customer_id,
        )

        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer not found.",
            )

        return CustomerService._format_customer(customer)

    @staticmethod
    def get_all_customers(db: Session):

        customers = CustomerRepository.get_all(db)

        return [
            CustomerService._format_customer(customer)
            for customer in customers
        ]

    @staticmethod
    def update_customer(
        db: Session,
        customer_id: int,
        customer_data: CustomerUpdate,
    ):

        customer = CustomerRepository.get_by_id(
            db,
            customer_id,
        )

        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer not found.",
            )

        data = customer_data.model_dump(
            exclude_unset=True,
        )

        try:
            updated_customer = CustomerRepository.update(
                db,
                customer,
                data,
            )

            return CustomerService._format_customer(
                updated_customer
            )

        except ValueError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(exc),
            )

        except IntegrityError:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Duplicate customer data is not allowed.",
            )

    @staticmethod
    def delete_customer(
        db: Session,
        customer_id: int,
    ):

        customer = CustomerRepository.get_by_id(
            db,
            customer_id,
        )

        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer not found.",
            )

        CustomerRepository.delete(db, customer)

        return {
            "message": "Customer deleted successfully."
        }
