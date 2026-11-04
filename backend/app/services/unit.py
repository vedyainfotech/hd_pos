from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.unit import Unit
from app.repositories.unit import UnitRepository
from app.schemas.unit import UnitCreate, UnitUpdate


class UnitService:

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
    ):
        return UnitRepository.get_all(
            db,
            include_inactive=include_inactive,
        )

    @staticmethod
    def get_by_id(
        db: Session,
        unit_id: int,
    ):
        unit = UnitRepository.get_by_id(db, unit_id)

        if not unit:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Unit not found",
            )

        return unit

    @staticmethod
    def create(
        db: Session,
        data: UnitCreate,
    ):
        name = data.name.strip()

        if not name:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unit name is required",
            )

        existing = UnitRepository.get_by_name(db, name)

        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Unit already exists",
            )

        unit = Unit(
            name=name,
            status=True,
        )

        return UnitRepository.create(db, unit)

    @staticmethod
    def update(
        db: Session,
        unit_id: int,
        data: UnitUpdate,
    ):
        unit = UnitService.get_by_id(db, unit_id)

        name = data.name.strip()

        if not name:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unit name is required",
            )

        existing = UnitRepository.get_by_name(db, name)

        if existing and existing.id != unit_id:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Unit already exists",
            )

        unit.name = name
        unit.status = data.status

        return UnitRepository.update(db, unit)

    @staticmethod
    def update_status(
        db: Session,
        unit_id: int,
        status: bool,
    ):
        unit = UnitService.get_by_id(db, unit_id)

        unit.status = status

        return UnitRepository.update(db, unit)