from pydantic import BaseModel, ConfigDict


class RoleCreate(BaseModel):
    name: str


class RoleUpdate(BaseModel):
    name: str | None = None
    status: bool | None = None


class RoleStatusUpdate(BaseModel):
    status: bool


class RoleResponse(BaseModel):
    id: int
    name: str
    status: bool

    model_config = ConfigDict(from_attributes=True)