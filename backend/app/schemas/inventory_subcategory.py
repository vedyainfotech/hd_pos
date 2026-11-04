from pydantic import BaseModel, ConfigDict


class InventorySubCategoryCreate(BaseModel):
    category_id: int
    name: str
    status: bool = True


class InventorySubCategoryUpdate(BaseModel):
    category_id: int
    name: str
    status: bool


class InventorySubCategoryStatusUpdate(BaseModel):
    status: bool


class InventorySubCategoryResponse(BaseModel):
    id: int
    category_id: int
    name: str
    status: bool

    model_config = ConfigDict(from_attributes=True)