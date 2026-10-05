from pydantic import BaseModel, ConfigDict


class InventoryCategoryCreate(BaseModel):
    name: str
    status: bool = True


class InventoryCategoryUpdate(BaseModel):
    name: str
    status: bool


class InventoryCategoryStatusUpdate(BaseModel):
    status: bool


class InventoryCategoryResponse(BaseModel):
    id: int
    name: str
    status: bool

    model_config = ConfigDict(from_attributes=True)