
from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, Field


# Create a new assignment
class OrderSelectionAssignmentCreate(BaseModel):
    customer_id: int
    address_id: int
    delivery_date: date
    category_id: int
    sub_category_id: int
    quantity: int = Field(gt=0)


# Request to save operator's selection
class OrderSelectionResolveRequest(BaseModel):
    selected_sub_category_id: int
    selected_item_id: int


# Assignment response
class OrderSelectionAssignmentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    customer_id: int
    address_id: int
    delivery_date: date
    category_id: int
    sub_category_id: int
    quantity: int
    selected_sub_category_id: int | None = None
    selected_item_id: int | None = None
    is_active: bool
    created_at: datetime
    updated_at: datetime


# Pending assignment shown in Flutter
class PendingOrderAssignmentResponse(BaseModel):
    id: int
    customer_id: int
    address_id: int
    delivery_date: date
    meal_category: str
    sub_category: str
    quantity: int


# Menu item response
class OrderSelectionItemResponse(BaseModel):
    id: int
    name: str
    category: str
    sub_category: str
    price: float
    status: bool


# Subcategory response
class OrderSelectionSubCategoryResponse(BaseModel):
    id: int
    name: str


# Address response
class OrderSelectionAddressResponse(BaseModel):
    id: int
    label: str
    address: str
    is_default: bool = False


# Customer response
class OrderSelectionCustomerResponse(BaseModel):
    id: int
    name: str
    mobile_number: str
    addresses: list[OrderSelectionAddressResponse] = Field(
        default_factory=list
    )
    status: bool = True


# Response after resolving an assignment
class OrderSelectionResolveResponse(BaseModel):
    message: str
    assignment_id: int
    selected_item_id: int
    delivery_date: date
