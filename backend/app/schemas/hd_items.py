from pydantic import BaseModel, Field, ConfigDict


class HDItemBase(BaseModel):
    category_id: int | None = None
    sub_category_id: int | None = None
    name: str = Field(..., min_length=1, max_length=100)
    price: float = Field(..., ge=0)
    same_as_category: bool = False


class HDItemCreate(HDItemBase):
    pass


class HDItemUpdate(HDItemBase):
    status: bool = True


class HDItemStatusUpdate(BaseModel):
    status: bool


class HDItemResponse(HDItemBase):
    id: int
    status: bool

    model_config = ConfigDict(from_attributes=True)