from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.roles import Role


def normalize_role_name(name: str) -> str:
    """
    Remove leading/trailing spaces and
    convert multiple spaces into a single space.
    """
    return " ".join(name.strip().split())


class RoleRepository:

    # ============================================================
    # GET ALL ROLES
    # ============================================================

    @staticmethod
    def get_all(
        db: Session,
        include_inactive: bool = False,
    ):
        query = select(Role)

        if not include_inactive:
            query = query.where(
                Role.status.is_(True)
            )

        query = query.order_by(Role.id)

        result = db.execute(query)

        return result.scalars().all()

    # ============================================================
    # GET ROLE BY ID
    # ============================================================

    @staticmethod
    def get_by_id(
        db: Session,
        role_id: int,
    ):
        result = db.execute(
            select(Role).where(
                Role.id == role_id
            )
        )

        return result.scalar_one_or_none()

    # ============================================================
    # GET ROLE BY NAME
    # ============================================================

    @staticmethod
    def get_by_name(
        db: Session,
        name: str,
    ):
        normalized_name = normalize_role_name(
            name
        )

        result = db.execute(
            select(Role).where(
                func.lower(
                    func.regexp_replace(
                        Role.name,
                        r"\s+",
                        " ",
                        "g",
                    )
                )
                == normalized_name.lower()
            )
        )

        return result.scalar_one_or_none()

    # ============================================================
    # CREATE ROLE
    # ============================================================

    @staticmethod
    def create(
        db: Session,
        name: str,
    ):
        role = Role(
            name=normalize_role_name(name),
            status=True,
        )

        db.add(role)
        db.commit()
        db.refresh(role)

        return role

    # ============================================================
    # UPDATE ROLE
    # ============================================================

    @staticmethod
    def update(
        db: Session,
        role: Role,
        name: str | None = None,
        status: bool | None = None,
    ):
        if name is not None:
            role.name = normalize_role_name(
                name
            )

        if status is not None:
            role.status = status

        db.commit()
        db.refresh(role)

        return role

    # ============================================================
    # UPDATE ROLE STATUS
    # ============================================================

    @staticmethod
    def update_status(
        db: Session,
        role: Role,
        status: bool,
    ):
        role.status = status

        db.commit()
        db.refresh(role)

        return role