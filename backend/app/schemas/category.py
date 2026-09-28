from datetime import time

from pydantic import BaseModel, ConfigDict


class CategoryCreate(BaseModel):
    name: str
    allotment_time: time
    status: bool = True


class CategoryUpdate(BaseModel):
    name: str
    allotment_time: time
    status: bool


class CategoryStatusUpdate(BaseModel):
    status: bool


class CategoryResponse(BaseModel):
    id: int
    name: str
    allotment_time: time
    status: bool

    model_config = ConfigDict(
        from_attributes=True,
    )