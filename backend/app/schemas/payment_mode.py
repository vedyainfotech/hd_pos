from pydantic import BaseModel, Field


class PaymentModeCreate(BaseModel):
    name: str = Field(
        ...,
        min_length=1,
        max_length=100,
    )
    status: bool = True


class PaymentModeUpdate(BaseModel):
    name: str = Field(
        ...,
        min_length=1,
        max_length=100,
    )
    status: bool


class PaymentModeStatusUpdate(BaseModel):
    status: bool


class PaymentModeResponse(BaseModel):
    id: int
    name: str
    status: bool

    class Config:
        from_attributes = True