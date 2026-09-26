from pydantic import BaseModel, ConfigDict


class CategoryCreate(BaseModel):
    name: str


class CategoryUpdate(BaseModel):
    name: str


class CategoryStatusUpdate(BaseModel):
    status: bool


class CategoryResponse(BaseModel):
    id: int
    name: str
    status: bool

    model_config = ConfigDict(from_attributes=True)