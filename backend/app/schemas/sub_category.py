from decimal import Decimal

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    field_validator,
)


class SubCategoryCreate(BaseModel):
    category_id: int

    name: str = Field(
        ...,
        min_length=1,
        max_length=100,
    )

    price: Decimal = Field(
        ...,
        ge=0,
        max_digits=10,
        decimal_places=2,
    )

    @field_validator("name")
    @classmethod
    def validate_name(
        cls,
        value: str,
    ) -> str:
        value = value.strip()

        if not value:
            raise ValueError(
                "Sub category name cannot be empty"
            )

        return value


class SubCategoryUpdate(BaseModel):
    category_id: int

    name: str = Field(
        ...,
        min_length=1,
        max_length=100,
    )

    price: Decimal = Field(
        ...,
        ge=0,
        max_digits=10,
        decimal_places=2,
    )

    status: bool

    @field_validator("name")
    @classmethod
    def validate_name(
        cls,
        value: str,
    ) -> str:
        value = value.strip()

        if not value:
            raise ValueError(
                "Sub category name cannot be empty"
            )

        return value


class SubCategoryStatusUpdate(BaseModel):
    status: bool


class SubCategoryResponse(BaseModel):
    id: int
    category_id: int
    name: str
    price: Decimal
    status: bool

    model_config = ConfigDict(
        from_attributes=True,
    )