
import re
import unicodedata

from fastapi import HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.repositories.roles import RoleRepository


def normalize_role_name(name: str) -> str:
    """
    Remove all whitespace and normalize capitalization for
    duplicate comparisons. Preserve readable spacing separately
    when validating and storing the name.
    """
    name = unicodedata.normalize("NFKC", name or "")
    return re.sub(r"\s+", "", name).casefold()


def validate_role_name(name: str) -> str:
    """Normalize and validate a role name."""

    # Normalize Unicode and clean leading/trailing spaces.
    name = unicodedata.normalize("NFKC", name or "").strip()

    # Collapse multiple spaces between words for storage.
    name = " ".join(name.split())

    if not name:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Role name cannot be empty",
        )

    if len(name) > 100:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Role name cannot exceed 100 characters",
        )

    # Allow letters and spaces only.
    if not re.fullmatch(r"[A-Za-z]+(?: [A-Za-z]+)*", name):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Role name can contain only letters and spaces",
        )

    # Reject words containing only one letter.
    if any(len(word) < 2 for word in name.split()):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Each word in a role name must have at least 2 letters",
        )

    return name


class RoleService:

    @staticmethod
    def get_roles(
        db: Session,
        include_inactive: bool = False,
    ):
        return RoleRepository.get_all(
            db,
            include_inactive=include_inactive,
        )

    @staticmethod
    def get_role(
        db: Session,
        role_id: int,
    ):
        role = RoleRepository.get_by_id(db, role_id)

        if not role:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Role not found",
            )

        return role

    @staticmethod
    def create_role(
        db: Session,
        name: str,
    ):
        name = validate_role_name(name)
        comparison_name = normalize_role_name(name)

        # Check active and inactive roles.
        for existing_role in RoleRepository.get_all(
            db,
            include_inactive=True,
        ):
            if normalize_role_name(existing_role.name) == comparison_name:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Role already exists",
                )

        try:
            return RoleRepository.create(db, name)

        except IntegrityError as exc:
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Role already exists",
            ) from exc

    @staticmethod
    def update_role(
        db: Session,
        role_id: int,
        name: str | None = None,
        status: bool | None = None,
    ):
        role = RoleRepository.get_by_id(db, role_id)

        if not role:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Role not found",
            )

        if name is not None:
            name = validate_role_name(name)
            comparison_name = normalize_role_name(name)

            for existing_role in RoleRepository.get_all(
                db,
                include_inactive=True,
            ):
                # Do not compare the role being updated against itself.
                if existing_role.id == role_id:
                    continue

                if normalize_role_name(existing_role.name) == comparison_name:
                    raise HTTPException(
                        status_code=status.HTTP_409_CONFLICT,
                        detail="Role already exists",
                    )

        try:
            return RoleRepository.update(
                db,
                role,
                name=name,
                status=status,
            )

        except IntegrityError as exc:
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Role already exists",
            ) from exc

    @staticmethod
    def update_role_status(
        db: Session,
        role_id: int,
        status: bool,
    ):
        role = RoleRepository.get_by_id(db, role_id)

        if not role:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Role not found",
            )

        return RoleRepository.update_status(
            db,
            role,
            status,
        )
