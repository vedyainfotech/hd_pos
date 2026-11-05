from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.repositories.permission import PermissionRepository


class PermissionService:

    @staticmethod
    def get_roles(db: Session):
        return PermissionRepository.get_roles(db)

    @staticmethod
    def get_screens(db: Session):
        return PermissionRepository.get_screens(db)

    @staticmethod
    def get_role_permissions(db: Session, role_id: int):
        role = PermissionRepository.get_role(db, role_id)

        if role is None:
            raise HTTPException(
                status_code=404,
                detail="Role not found",
            )

        rows = PermissionRepository.get_role_permissions(
            db,
            role_id,
        )

        return {
            "role_id": role.id,
            "role_name": role.name,
            "permissions": [
                {
                    "screen_id": screen.id,
                    "screen_key": screen.screen_key,
                    "screen_name": screen.screen_name,
                    "route_name": screen.route_name,
                    "can_view": permission.can_view,
                }
                for permission, screen in rows
            ],
        }

    @staticmethod
    def save_role_permissions(
        db: Session,
        role_id: int,
        permissions: list,
    ):
        role = PermissionRepository.get_role(db, role_id)

        if role is None:
            raise HTTPException(
                status_code=404,
                detail="Role not found",
            )

        active_screen_ids = {
            screen.id
            for screen in PermissionRepository.get_screens(db)
        }

        for item in permissions:
            if item.screen_id not in active_screen_ids:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid or inactive screen ID: {item.screen_id}",
                )

        PermissionRepository.save_role_permissions(
            db,
            role_id,
            [
                {
                    "screen_id": item.screen_id,
                    "can_view": item.can_view,
                }
                for item in permissions
            ],
        )

        return PermissionService.get_role_permissions(
            db,
            role_id,
        )