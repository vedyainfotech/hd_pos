
from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.services.order_selection import OrderSelectionService
from app.schemas.order_selection import (
    OrderSelectionAssignmentCreate,
    OrderSelectionAssignmentResponse,
    OrderSelectionResolveRequest,
    OrderSelectionResolveResponse,
    PendingOrderAssignmentResponse,
    OrderSelectionCustomerResponse,
    OrderSelectionSubCategoryResponse,
    OrderSelectionItemResponse,
)


router = APIRouter(
    prefix="/order-selection",
    tags=["Order Selection"],
)


# 1. Get pending assignments for selected date
@router.get(
    "/pending",
    response_model=list[PendingOrderAssignmentResponse],
)
def get_pending_assignments(
    delivery_date: date = Query(...),
    db: Session = Depends(get_db),
):
    service = OrderSelectionService(db)

    return service.get_pending_assignments(delivery_date)


# 2. Get customer details for an assignment
@router.get(
    "/assignments/{assignment_id}/customer",
    response_model=OrderSelectionCustomerResponse,
)
def get_assignment_customer(
    assignment_id: int,
    db: Session = Depends(get_db),
):
    service = OrderSelectionService(db)

    assignment = service.repository.get_assignment_by_id(assignment_id)

    if assignment is None:
        raise HTTPException(status_code=404, detail="Assignment not found")

    try:
        return service.get_customer(assignment.customer_id)
    except ValueError as error:
        raise HTTPException(status_code=404, detail=str(error))


# 3. Get subcategories for an assignment
@router.get(
    "/assignments/{assignment_id}/subcategories",
    response_model=list[OrderSelectionSubCategoryResponse],
)
def get_assignment_subcategories(
    assignment_id: int,
    db: Session = Depends(get_db),
):
    service = OrderSelectionService(db)

    try:
        return service.get_subcategories(assignment_id)
    except ValueError as error:
        raise HTTPException(status_code=404, detail=str(error))


# 4. Get daily menu items for selected subcategory
@router.get(
    "/assignments/{assignment_id}/items",
    response_model=list[OrderSelectionItemResponse],
)
def get_assignment_items(
    assignment_id: int,
    sub_category_id: int,
    db: Session = Depends(get_db),
):
    service = OrderSelectionService(db)

    try:
        return service.get_available_items(
            assignment_id,
            sub_category_id,
        )
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))


# 5. Create a pending assignment
@router.post(
    "/assignments",
    response_model=OrderSelectionAssignmentResponse,
    status_code=201,
)
def create_assignment(
    data: OrderSelectionAssignmentCreate,
    db: Session = Depends(get_db),
):
    service = OrderSelectionService(db)

    try:
        return service.create_assignment(data.model_dump())
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))


# 6. Save selected item and resolve assignment
@router.post(
    "/assignments/{assignment_id}/resolve",
    response_model=OrderSelectionResolveResponse,
)
def resolve_assignment(
    assignment_id: int,
    data: OrderSelectionResolveRequest,
    db: Session = Depends(get_db),
):
    service = OrderSelectionService(db)

    try:
        assignment = service.resolve_assignment(
            assignment_id=assignment_id,
            selected_sub_category_id=data.selected_sub_category_id,
            selected_item_id=data.selected_item_id,
        )

        return {
            "message": "Item selection saved successfully",
            "assignment_id": assignment.id,
            "selected_item_id": assignment.selected_item_id,
            "delivery_date": assignment.delivery_date,
        }

    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))
