from decimal import Decimal

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    field_validator,
)


class ItemCreate(BaseModel):
    category_id: int
    sub_category_id: int
    name: str = Field(
        ...,
        min_length=1,
        max_length=150,
    )
    price: Decimal = Field(
        ...,
        ge=0,
        max_digits=10,
        decimal_places=2,
    )
    same_as_category: bool = False

    @field_validator("name")
    @classmethod
    def validate_name(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError("Item name cannot be empty")

        return value


class ItemUpdate(BaseModel):
    category_id: int
    sub_category_id: int
    name: str = Field(
        ...,
        min_length=1,
        max_length=150,
    )
    price: Decimal = Field(
        ...,
        ge=0,
        max_digits=10,
        decimal_places=2,
    )
    same_as_category: bool
    status: bool

    @field_validator("name")
    @classmethod
    def validate_name(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError("Item name cannot be empty")

        return value


class ItemStatusUpdate(BaseModel):
    status: bool


class ItemResponse(BaseModel):
    id: int
    category_id: int
    sub_category_id: int
    name: str
    price: Decimal
    same_as_category: bool
    status: bool

    model_config = ConfigDict(
        from_attributes=True,
    )