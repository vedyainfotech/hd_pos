from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.roles import Role
from app.models.screen import Screen
from app.models.role_permission import RolePermission


class PermissionRepository:

    @staticmethod
    def get_roles(db: Session):
        query = (
            select(Role)
            .where(Role.status.is_(True))
            .order_by(Role.id)
        )
        return list(db.scalars(query).all())

    @staticmethod
    def get_screens(db: Session):
        query = (
            select(Screen)
            .where(Screen.is_active.is_(True))
            .order_by(Screen.id)
        )
        return list(db.scalars(query).all())

    @staticmethod
    def get_role(db: Session, role_id: int):
        return db.scalar(
            select(Role).where(Role.id == role_id)
        )

    @staticmethod
    def get_role_permissions(db: Session, role_id: int):
        query = (
            select(RolePermission, Screen)
            .join(Screen, Screen.id == RolePermission.screen_id)
            .where(RolePermission.role_id == role_id)
            .order_by(Screen.id)
        )
        return db.execute(query).all()

    @staticmethod
    def save_role_permissions(
        db: Session,
        role_id: int,
        permissions: list[dict],
    ):
        for item in permissions:
            permission = db.scalar(
                select(RolePermission).where(
                    RolePermission.role_id == role_id,
                    RolePermission.screen_id == item["screen_id"],
                )
            )

            if permission is None:
                permission = RolePermission(
                    role_id=role_id,
                    screen_id=item["screen_id"],
                    can_view=item["can_view"],
                )
                db.add(permission)
            else:
                permission.can_view = item["can_view"]

        db.commit()

        return PermissionRepository.get_role_permissions(db, role_id)