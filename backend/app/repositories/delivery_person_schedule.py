
from datetime import date

from sqlalchemy.orm import Session

from app.models.delivery_person_schedule import DeliveryPersonSchedule


class DeliveryPersonScheduleRepository:

    @staticmethod
    def get_by_date(db: Session, schedule_date: date):
        return (
            db.query(DeliveryPersonSchedule)
            .filter(DeliveryPersonSchedule.schedule_date == schedule_date)
            .all()
        )

    @staticmethod
    def get_by_date_and_category(
        db: Session,
        schedule_date: date,
        category_id: int,
    ):
        return (
            db.query(DeliveryPersonSchedule)
            .filter(
                DeliveryPersonSchedule.schedule_date == schedule_date,
                DeliveryPersonSchedule.category_id == category_id,
            )
            .all()
        )

    @staticmethod
    def replace_category_schedule(
        db: Session,
        schedule_date: date,
        category_id: int,
        delivery_person_ids: list[int],
    ):
        # Remove the existing assignments for this category and date.
        (
            db.query(DeliveryPersonSchedule)
            .filter(
                DeliveryPersonSchedule.schedule_date == schedule_date,
                DeliveryPersonSchedule.category_id == category_id,
            )
            .delete(synchronize_session=False)
        )

        # Insert the selected delivery persons.
        records = [
            DeliveryPersonSchedule(
                delivery_person_id=person_id,
                category_id=category_id,
                schedule_date=schedule_date,
            )
            for person_id in set(delivery_person_ids)
        ]

        db.add_all(records)
        db.commit()

        return records
