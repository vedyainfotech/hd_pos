from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.unit import Unit


class UnitRepository:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
    ):
        query = select(Unit).order_by(Unit.id)

        if not include_inactive:
            query = query.where(Unit.status.is_(True))

        return list(db.scalars(query).all())

    @staticmethod
    def get_by_id(
        db: Session,
        unit_id: int,
    ):
        return db.get(Unit, unit_id)

    @staticmethod
    def get_by_name(
        db: Session,
        name: str,
    ):
        # Remove all spaces and compare case-insensitively
        normalized_name = "".join(name.split()).lower()

        units = db.scalars(
            select(Unit)
        ).all()

        for unit in units:
            existing_name = "".join(
                unit.name.split()
            ).lower()

            if existing_name == normalized_name:
                return unit

        return None

    @staticmethod
    def create(
        db: Session,
        unit: Unit,
    ):
        db.add(unit)
        db.commit()
        db.refresh(unit)

        return unit

    @staticmethod
    def update(
        db: Session,
        unit: Unit,
    ):
        db.commit()
        db.refresh(unit)

        return unit