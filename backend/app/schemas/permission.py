from pydantic import BaseModel, ConfigDict


class ScreenResponse(BaseModel):
    id: int
    screen_key: str
    screen_name: str
    route_name: str
    is_active: bool

    model_config = ConfigDict(from_attributes=True)


class RolePermissionItem(BaseModel):
    screen_id: int
    can_view: bool


class RolePermissionsUpdate(BaseModel):
    permissions: list[RolePermissionItem]