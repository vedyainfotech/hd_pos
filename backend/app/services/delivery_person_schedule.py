
from datetime import date

from sqlalchemy.orm import Session

from app.models.category import Category
from app.models.delivery_person import DeliveryPerson
from app.repositories.delivery_person_schedule import (
    DeliveryPersonScheduleRepository,
)


class DeliveryPersonScheduleService:

    @staticmethod
    def get_schedule(db: Session, schedule_date: date):
        return DeliveryPersonScheduleRepository.get_by_date(
            db=db,
            schedule_date=schedule_date,
        )

    @staticmethod
    def save_category_schedule(
        db: Session,
        schedule_date: date,
        category_id: int,
        delivery_person_ids: list[int],
    ):
        # Validate that the category exists.
        category = (
            db.query(Category)
            .filter(Category.id == category_id)
            .first()
        )

        if category is None:
            raise ValueError("Category not found.")

        # Validate that all selected delivery persons exist.
        unique_person_ids = set(delivery_person_ids)

        if unique_person_ids:
            existing_ids = {
                row[0]
                for row in (
                    db.query(DeliveryPerson.id)
                    .filter(DeliveryPerson.id.in_(unique_person_ids))
                    .all()
                )
            }

            missing_ids = unique_person_ids - existing_ids

            if missing_ids:
                raise ValueError(
                    f"Delivery person IDs not found: {sorted(missing_ids)}"
                )

        return DeliveryPersonScheduleRepository.replace_category_schedule(
            db=db,
            schedule_date=schedule_date,
            category_id=category_id,
            delivery_person_ids=list(unique_person_ids),
        )
