from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.delivery_person import DeliveryPerson


class DeliveryPersonRepository:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
    ) -> list[DeliveryPerson]:

        query = select(DeliveryPerson)

        if not include_inactive:
            query = query.where(
                DeliveryPerson.status.is_(True)
            )

        query = query.order_by(
            DeliveryPerson.id
        )

        return list(
            db.scalars(query).all()
        )

    @staticmethod
    def get_by_id(
        db: Session,
        delivery_person_id: int,
    ) -> DeliveryPerson | None:

        query = select(DeliveryPerson).where(
            DeliveryPerson.id == delivery_person_id
        )

        return db.scalar(query)

    @staticmethod
    def create(
        db: Session,
        delivery_person: DeliveryPerson,
    ) -> DeliveryPerson:

        db.add(delivery_person)

        db.commit()

        db.refresh(delivery_person)

        return delivery_person

    @staticmethod
    def update(
        db: Session,
        delivery_person: DeliveryPerson,
    ) -> DeliveryPerson:

        db.commit()

        db.refresh(delivery_person)

        return delivery_person

    @staticmethod
    def update_status(
        db: Session,
        delivery_person: DeliveryPerson,
        status: bool,
    ) -> DeliveryPerson:

        delivery_person.status = status

        db.commit()

        db.refresh(delivery_person)

        return delivery_person