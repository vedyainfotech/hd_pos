from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.roles import (
    RoleCreate,
    RoleResponse,
    RoleStatusUpdate,
    RoleUpdate,
)
from app.services.roles import RoleService


router = APIRouter(
    prefix="/api/roles",
    tags=["Roles"],
)


@router.get(
    "/",
    response_model=list[RoleResponse],
)
def get_roles(
    include_inactive: bool = Query(False),
    db: Session = Depends(get_db),
):
    return RoleService.get_roles(
        db,
        include_inactive=include_inactive,
    )


@router.get(
    "/{role_id}",
    response_model=RoleResponse,
)
def get_role(
    role_id: int,
    db: Session = Depends(get_db),
):
    return RoleService.get_role(
        db,
        role_id,
    )


@router.post(
    "/",
    response_model=RoleResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_role(
    role_data: RoleCreate,
    db: Session = Depends(get_db),
):
    return RoleService.create_role(
        db,
        role_data.name,
    )


@router.put(
    "/{role_id}",
    response_model=RoleResponse,
)
def update_role(
    role_id: int,
    role_data: RoleUpdate,
    db: Session = Depends(get_db),
):
    return RoleService.update_role(
        db,
        role_id,
        name=role_data.name,
        status=role_data.status,
    )


@router.patch(
    "/{role_id}/status",
    response_model=RoleResponse,
)
def update_role_status(
    role_id: int,
    role_data: RoleStatusUpdate,
    db: Session = Depends(get_db),
):
    return RoleService.update_role_status(
        db,
        role_id,
        role_data.status,
    )