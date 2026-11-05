
from fastapi import APIRouter, Depends, Path, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.customer import (
    CustomerCreate,
    CustomerUpdate,
    CustomerResponse,
)
from app.services.customer import CustomerService


router = APIRouter(
    prefix="/customers",
    tags=["Customers"],
)


# =========================================
# 1. REGISTER NEW CUSTOMER
# =========================================
@router.post(
    "/",
    response_model=CustomerResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new customer",
)
def create_customer(
    customer_data: CustomerCreate,
    db: Session = Depends(get_db),
):
    return CustomerService.create_customer(
        db,
        customer_data,
    )


# =========================================
# 2. GET ALL CUSTOMERS
# =========================================
@router.get(
    "/",
    response_model=list[CustomerResponse],
    summary="Get all customers",
)
def get_all_customers(
    db: Session = Depends(get_db),
):
    return CustomerService.get_all_customers(db)


# =========================================
# 3. GET CUSTOMER BY ID
# =========================================
@router.get(
    "/{customer_id}",
    response_model=CustomerResponse,
    summary="Get customer by ID",
)
def get_customer(
    customer_id: int = Path(gt=0),
    db: Session = Depends(get_db),
):
    return CustomerService.get_customer(
        db,
        customer_id,
    )


# =========================================
# 4. UPDATE CUSTOMER
# =========================================
@router.put(
    "/{customer_id}",
    response_model=CustomerResponse,
    summary="Update customer",
)
def update_customer(
    customer_data: CustomerUpdate,
    customer_id: int = Path(gt=0),
    db: Session = Depends(get_db),
):
    return CustomerService.update_customer(
        db,
        customer_id,
        customer_data,
    )


# =========================================
# 5. DELETE CUSTOMER
# =========================================
@router.delete(
    "/{customer_id}",
    summary="Delete customer",
)
def delete_customer(
    customer_id: int = Path(gt=0),
    db: Session = Depends(get_db),
):
    return CustomerService.delete_customer(
        db,
        customer_id,
    )
