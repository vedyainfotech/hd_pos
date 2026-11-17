
from sqlalchemy.orm import Session, joinedload

from app.models.customer import Customer
from app.models.customer_phone_number import CustomerPhoneNumber
from app.models.customer_address import CustomerAddress


class CustomerRepository:

    @staticmethod
    def create(db: Session, customer_data: dict):
        try:
            customer = Customer(
                customer_code=customer_data["customer_code"],
                name=customer_data["name"],
                email=customer_data.get("email"),
            )

            # Save customer phone numbers
            phone_numbers = customer_data.get("phone_numbers", [])

            if len(phone_numbers) != len(set(phone_numbers)):
                raise ValueError("Duplicate phone numbers are not allowed.")

            for phone in phone_numbers:
                customer.phone_numbers.append(
                    CustomerPhoneNumber(phone_number=phone)
                )

            # Save customer addresses
            addresses = customer_data.get("addresses", [])

            address_codes = [
                address["address_code"] for address in addresses
            ]

            if len(address_codes) != len(set(address_codes)):
                raise ValueError("Duplicate address codes are not allowed.")

            for address_data in addresses:
                customer.addresses.append(
                    CustomerAddress(**address_data)
                )

            db.add(customer)
            db.commit()
            db.refresh(customer)

            return customer

        except Exception:
            db.rollback()
            raise

    @staticmethod
    def get_by_id(db: Session, customer_id: int):
        return (
            db.query(Customer)
            .options(
                joinedload(Customer.phone_numbers),
                joinedload(Customer.addresses),
            )
            .filter(Customer.id == customer_id)
            .first()
        )

    @staticmethod
    def get_by_code(db: Session, customer_code: str):
        return (
            db.query(Customer)
            .filter(Customer.customer_code == customer_code)
            .first()
        )

    @staticmethod
    def get_all(db: Session):
        return (
            db.query(Customer)
            .options(
                joinedload(Customer.phone_numbers),
                joinedload(Customer.addresses),
            )
            .order_by(Customer.id.desc())
            .all()
        )

   
    @staticmethod
    def update(db: Session, customer: Customer, customer_data: dict):
        try:
            if "name" in customer_data:
                customer.name = customer_data["name"]

            if "email" in customer_data:
                customer.email = customer_data["email"]

            # -----------------------------------------
            # UPDATE PHONE NUMBERS WITHOUT RECREATING
            # EXISTING PHONE RECORDS
            # -----------------------------------------
            if "phone_numbers" in customer_data:
                phone_numbers = [
                    phone.strip()
                    for phone in (customer_data["phone_numbers"] or [])
                    if phone and phone.strip()
                ]

                if len(phone_numbers) != len(set(phone_numbers)):
                    raise ValueError(
                        "Duplicate phone numbers are not allowed."
                    )

                existing_phones = {
                    item.phone_number: item
                    for item in customer.phone_numbers
                }

                incoming_phones = set(phone_numbers)

                # Retain existing phone records.
                retained_phones = [
                    item
                    for number, item in existing_phones.items()
                    if number in incoming_phones
                ]

                # Remove only numbers that are no longer submitted.
                customer.phone_numbers[:] = retained_phones

                # Flush deletions before inserting new numbers.
                db.flush()

                # Insert only genuinely new numbers.
                for phone in phone_numbers:
                    if phone not in existing_phones:
                        customer.phone_numbers.append(
                            CustomerPhoneNumber(
                                phone_number=phone
                            )
                        )

            # -----------------------------------------
            # UPDATE ADDRESSES WITHOUT RECREATING
            # EXISTING ADDRESS RECORDS
            # -----------------------------------------
            if "addresses" in customer_data:
                addresses = customer_data["addresses"] or []

                address_codes = [
                    address["address_code"]
                    for address in addresses
                ]

                if len(address_codes) != len(set(address_codes)):
                    raise ValueError(
                        "Duplicate address codes are not allowed."
                    )

                existing_addresses = {
                    item.address_code: item
                    for item in customer.addresses
                }

                incoming_codes = set(address_codes)

                # Retain addresses whose codes still exist.
                retained_addresses = [
                    item
                    for code, item in existing_addresses.items()
                    if code in incoming_codes
                ]

                # Remove only deleted addresses.
                customer.addresses[:] = retained_addresses

                # Ensure deletions happen before any new inserts.
                db.flush()

                # Update existing addresses or insert new ones.
                allowed_fields = {
                    column.name
                    for column in CustomerAddress.__table__.columns
                } - {"id", "customer_id"}

                for address_data in addresses:
                    address_code = address_data["address_code"]
                    existing_address = existing_addresses.get(
                        address_code
                    )

                    values = {
                        key: value
                        for key, value in address_data.items()
                        if key in allowed_fields
                    }

                    if existing_address:
                        # Update existing database record.
                        for key, value in values.items():
                            setattr(existing_address, key, value)
                    else:
                        # Create only a genuinely new address.
                        customer.addresses.append(
                            CustomerAddress(**values)
                        )

            db.commit()
            db.refresh(customer)

            return customer

        except Exception:
            db.rollback()
            raise
