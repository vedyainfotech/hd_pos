from datetime import date, datetime
from pydantic import BaseModel, Field, ConfigDict


# ---------------------------------
# Save Menu Schedule
# ---------------------------------

class MenuScheduleSave(BaseModel):
    delivery_date: date
    category_id: int
    item_ids: list[int] = Field(
        default_factory=list,
        description="List of HD item IDs selected for this category and date",
    )


# ---------------------------------
# Scheduled Item Response
# ---------------------------------

class MenuScheduleItemResponse(BaseModel):
    id: int
    item_id: int
    item_name: str
    price: float
    sub_category_id: int | None = None
    sub_category_name: str | None = None

    model_config = ConfigDict(from_attributes=True)


# ---------------------------------
# Scheduled Menu Response
# ---------------------------------

class MenuScheduleResponse(BaseModel):
    id: int
    delivery_date: date
    category_id: int
    category_name: str
    items: list[MenuScheduleItemResponse] = Field(
        default_factory=list
    )


# ---------------------------------
# Available Item Response
# ---------------------------------

class AvailableMenuItemResponse(BaseModel):
    id: int
    name: str
    price: float
    category_id: int | None = None
    sub_category_id: int | None = None
    sub_category_name: str | None = None

    model_config = ConfigDict(from_attributes=True)


# ---------------------------------
# Available Subcategory Response
# ---------------------------------

class AvailableSubCategoryResponse(BaseModel):
    id: int
    name: str
    items: list[AvailableMenuItemResponse] = Field(
        default_factory=list
    )


# ---------------------------------
# Available Category Response
# ---------------------------------

class AvailableMenuResponse(BaseModel):
    category_id: int
    category_name: str
    sub_categories: list[AvailableSubCategoryResponse] = Field(
        default_factory=list
    )


# ---------------------------------
# Menu Schedule Date Response
# ---------------------------------

class MenuScheduleDateResponse(BaseModel):
    delivery_date: date
    schedules: list[MenuScheduleResponse] = Field(
        default_factory=list
    )