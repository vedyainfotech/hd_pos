from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.permission import RolePermissionsUpdate
from app.services.permission import PermissionService

router = APIRouter(
    prefix="/permissions",
    tags=["Permissions"],
)


@router.get("/roles")
def get_roles(db: Session = Depends(get_db)):
    return PermissionService.get_roles(db)


@router.get("/screens")
def get_screens(db: Session = Depends(get_db)):
    return PermissionService.get_screens(db)


@router.get("/roles/{role_id}")
def get_role_permissions(
    role_id: int,
    db: Session = Depends(get_db),
):
    try:
        return PermissionService.get_role_permissions(db, role_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.put("/roles/{role_id}")
def save_role_permissions(
    role_id: int,
    payload: RolePermissionsUpdate,
    db: Session = Depends(get_db),
):
    try:
        return PermissionService.save_role_permissions(
            db,
            role_id,
            payload.permissions,
        )
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))