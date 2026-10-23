
from decimal import Decimal
from typing import List

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ItemSubCategoryCreate(BaseModel):
    sub_category_id: int = Field(..., gt=0)
    price: Decimal = Field(
        ...,
        ge=0,
        max_digits=10,
        decimal_places=2,
    )
    same_as_sub_category: bool = False


class ItemCreate(BaseModel):
    category_id: int = Field(..., gt=0)
    item_name: str = Field(..., min_length=1, max_length=150)
    sub_categories: List[ItemSubCategoryCreate] = Field(
        ...,
        min_length=1,
    )
    status: bool = True

    @field_validator("item_name")
    @classmethod
    def validate_item_name(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError("Item name cannot be empty")

        return value

    @field_validator("sub_categories")
    @classmethod
    def validate_sub_categories(
        cls,
        value: List[ItemSubCategoryCreate],
    ) -> List[ItemSubCategoryCreate]:
        ids = [item.sub_category_id for item in value]

        if len(ids) != len(set(ids)):
            raise ValueError("Duplicate subcategories are not allowed")

        if len(value) > 1 and any(
            item.same_as_sub_category for item in value
        ):
            raise ValueError(
                "same_as_sub_category can only be enabled "
                "when one subcategory is selected"
            )

        return value


class ItemSubCategoryUpdate(BaseModel):
    sub_category_id: int = Field(..., gt=0)
    price: Decimal = Field(
        ...,
        ge=0,
        max_digits=10,
        decimal_places=2,
    )
    same_as_sub_category: bool = False
    status: bool = True


class ItemUpdate(BaseModel):
    category_id: int = Field(..., gt=0)
    item_name: str = Field(..., min_length=1, max_length=150)
    sub_categories: List[ItemSubCategoryUpdate] = Field(
        ...,
        min_length=1,
    )
    status: bool

    @field_validator("item_name")
    @classmethod
    def validate_item_name(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError("Item name cannot be empty")

        return value

    @field_validator("sub_categories")
    @classmethod
    def validate_sub_categories(
        cls,
        value: List[ItemSubCategoryUpdate],
    ) -> List[ItemSubCategoryUpdate]:
        ids = [item.sub_category_id for item in value]

        if len(ids) != len(set(ids)):
            raise ValueError("Duplicate subcategories are not allowed")

        if len(value) > 1 and any(
            item.same_as_sub_category for item in value
        ):
            raise ValueError(
                "same_as_sub_category can only be enabled "
                "when one subcategory is selected"
            )

        return value


class ItemStatusUpdate(BaseModel):
    status: bool


class ItemSubCategoryResponse(BaseModel):
    id: int
    sub_category_id: int
    price: Decimal
    status: bool
    same_as_sub_category: bool

    model_config = ConfigDict(from_attributes=True)


class ItemResponse(BaseModel):
    id: int
    category_id: int
    item_name: str
    status: bool
    sub_categories: List[ItemSubCategoryResponse] = Field(
        default_factory=list
    )

    model_config = ConfigDict(from_attributes=True)


class ItemPriceLogResponse(BaseModel):
    l_sno: int
    fd_id: int
    sub_category_id: int
    old_price: Decimal
    new_price: Decimal
    fromdate: object

    model_config = ConfigDict(from_attributes=True)
