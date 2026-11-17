
from pydantic import BaseModel, ConfigDict, Field


class CustomerAddressCreate(BaseModel):
    address_code: str
    contact_name: str = Field(min_length=1, max_length=100)
    contact_number: str = Field(min_length=1, max_length=20)

    house_name: str | None = None
    house_flat_number: str | None = None
    address_type: str

    country: str
    state: str
    district: str
    area: str

    street: str | None = None
    landmark: str | None = None
    pincode: str = Field(min_length=1, max_length=6)

    location_link: str | None = None
    monthly_food_order: bool = False


class CustomerAddressResponse(CustomerAddressCreate):
    id: str


class CustomerCreate(BaseModel):
    name: str = Field(min_length=1, max_length=50)
    phone_numbers: list[str] = Field(min_length=1)
    email: str | None = None
    addresses: list[CustomerAddressCreate] = Field(default_factory=list)


class CustomerUpdate(BaseModel):
    name: str | None = Field(default=None, max_length=50)
    phone_numbers: list[str] | None = None
    email: str | None = None
    addresses: list[CustomerAddressCreate] | None = None


class CustomerResponse(BaseModel):
    id: str
    customer_code: str
    name: str
    phone_numbers: list[str]
    email: str | None = None
    addresses: list[CustomerAddressResponse] = Field(default_factory=list)

    model_config = ConfigDict(from_attributes=True)
