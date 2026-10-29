
from datetime import date

from pydantic import BaseModel, ConfigDict, Field


class DeliveryPersonScheduleSave(BaseModel):
    schedule_date: date
    category_id: int = Field(gt=0)
    delivery_person_ids: list[int] = Field(default_factory=list)


class DeliveryPersonScheduleResponse(BaseModel):
    id: int
    delivery_person_id: int
    category_id: int
    schedule_date: date

    model_config = ConfigDict(from_attributes=True)
