
from sqlalchemy import Column, Integer, String, Float, Boolean
from app.core.database import Base


class HDItem(Base):
    __tablename__ = "hd_items"

    id = Column(Integer, primary_key=True, index=True)
    category_id = Column(Integer, nullable=True)
    sub_category_id = Column(Integer, nullable=True)
    name = Column(String(100), nullable=False, index=True)
    price = Column(Float, nullable=False, default=0.0)
    same_as_category = Column(Boolean, nullable=False, default=False)
    status = Column(Boolean, nullable=False, default=True)
