
from sqlalchemy import Column, Date, ForeignKey, Integer
from sqlalchemy.orm import relationship

from app.core.database import Base

class DeliveryPersonSchedule(Base):
    __tablename__ = "delivery_person_schedules"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    delivery_person_id = Column(
        Integer,
        ForeignKey("delivery_persons.id", onupdate="CASCADE", ondelete="RESTRICT"),
        nullable=False,
    )

    category_id = Column(
        Integer,
        ForeignKey("categories.id", onupdate="CASCADE", ondelete="RESTRICT"),
        nullable=False,
    )

    schedule_date = Column(Date, nullable=False)

    delivery_person = relationship("DeliveryPerson")
    category = relationship("Category")
