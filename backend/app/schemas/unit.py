from pydantic import BaseModel, ConfigDict


class UnitCreate(BaseModel):
    name: str


class UnitUpdate(BaseModel):
    name: str
    status: bool


class UnitStatusUpdate(BaseModel):
    status: bool


class UnitResponse(BaseModel):
    id: int
    name: str
    status: bool

    model_config = ConfigDict(from_attributes=True)