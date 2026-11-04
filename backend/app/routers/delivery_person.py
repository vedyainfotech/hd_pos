from pathlib import Path

from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    HTTPException,
    UploadFile,
)
from fastapi.responses import FileResponse
from pydantic import ValidationError
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.delivery_person import (
    DeliveryPersonCreate,
    DeliveryPersonResponse,
    DeliveryPersonStatusUpdate,
    DeliveryPersonUpdate,
)
from app.services.delivery_person import (
    DeliveryPersonService,
)


router = APIRouter(
    prefix="/api/delivery-persons",
    tags=["Delivery Persons"],
)


def _create_data(
    name: str,
    contact_number: str,
    bank_name: str | None,
    account_number: str | None,
    ifsc_code: str | None,
    aadhaar_number: str | None,
    pan_card_number: str | None,
    driving_license: str | None,
) -> DeliveryPersonCreate:

    return DeliveryPersonCreate(
        name=name,
        contact_number=contact_number,
        bank_name=bank_name,
        account_number=account_number,
        ifsc_code=ifsc_code,
        aadhaar_number=aadhaar_number,
        pan_card_number=pan_card_number,
        driving_license=driving_license,
    )


def _update_data(
    name: str,
    contact_number: str,
    bank_name: str | None,
    account_number: str | None,
    ifsc_code: str | None,
    aadhaar_number: str | None,
    pan_card_number: str | None,
    driving_license: str | None,
    status: bool,
) -> DeliveryPersonUpdate:

    return DeliveryPersonUpdate(
        name=name,
        contact_number=contact_number,
        bank_name=bank_name,
        account_number=account_number,
        ifsc_code=ifsc_code,
        aadhaar_number=aadhaar_number,
        pan_card_number=pan_card_number,
        driving_license=driving_license,
        status=status,
    )


@router.get(
    "/",
    response_model=list[DeliveryPersonResponse],
)
def get_delivery_persons(
    include_inactive: bool = True,
    db: Session = Depends(get_db),
):

    return DeliveryPersonService.get_delivery_persons(
        db=db,
        include_inactive=include_inactive,
    )


@router.get(
    "/{delivery_person_id}",
    response_model=DeliveryPersonResponse,
)
def get_delivery_person(
    delivery_person_id: int,
    db: Session = Depends(get_db),
):

    person = (
        DeliveryPersonService.get_delivery_person(
            db=db,
            delivery_person_id=delivery_person_id,
        )
    )

    if person is None:
        raise HTTPException(
            status_code=404,
            detail="Delivery person not found",
        )

    return person


@router.post(
    "/",
    response_model=DeliveryPersonResponse,
    status_code=201,
)
async def create_delivery_person(
    name: str = Form(...),
    contact_number: str = Form(...),
    bank_name: str | None = Form(None),
    account_number: str | None = Form(None),
    ifsc_code: str | None = Form(None),
    aadhaar_number: str | None = Form(None),
    pan_card_number: str | None = Form(None),
    driving_license: str | None = Form(None),
    identity_proof: UploadFile = File(...),
    db: Session = Depends(get_db),
):

    try:

        data = _create_data(
            name,
            contact_number,
            bank_name,
            account_number,
            ifsc_code,
            aadhaar_number,
            pan_card_number,
            driving_license,
        )

        return (
            await DeliveryPersonService.create_delivery_person(
                db=db,
                data=data,
                identity_proof=identity_proof,
            )
        )

    except ValidationError as exc:

        raise HTTPException(
            status_code=422,
            detail=exc.errors(),
        )

    except ValueError as exc:

        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )

    except IntegrityError:

        db.rollback()

        raise HTTPException(
            status_code=409,
            detail="Unable to create delivery person",
        )


@router.put(
    "/{delivery_person_id}",
    response_model=DeliveryPersonResponse,
)
async def update_delivery_person(
    delivery_person_id: int,
    name: str = Form(...),
    contact_number: str = Form(...),
    bank_name: str | None = Form(None),
    account_number: str | None = Form(None),
    ifsc_code: str | None = Form(None),
    aadhaar_number: str | None = Form(None),
    pan_card_number: str | None = Form(None),
    driving_license: str | None = Form(None),
    status: bool = Form(...),
    identity_proof: UploadFile | None = File(None),
    db: Session = Depends(get_db),
):

    try:

        data = _update_data(
            name,
            contact_number,
            bank_name,
            account_number,
            ifsc_code,
            aadhaar_number,
            pan_card_number,
            driving_license,
            status,
        )

        person = (
            await DeliveryPersonService.update_delivery_person(
                db=db,
                delivery_person_id=delivery_person_id,
                data=data,
                identity_proof=identity_proof,
            )
        )

        if person is None:

            raise HTTPException(
                status_code=404,
                detail="Delivery person not found",
            )

        return person

    except ValidationError as exc:

        raise HTTPException(
            status_code=422,
            detail=exc.errors(),
        )

    except ValueError as exc:

        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )

    except IntegrityError:

        db.rollback()

        raise HTTPException(
            status_code=409,
            detail="Unable to update delivery person",
        )


@router.patch(
    "/{delivery_person_id}/status",
    response_model=DeliveryPersonResponse,
)
def update_delivery_person_status(
    delivery_person_id: int,
    data: DeliveryPersonStatusUpdate,
    db: Session = Depends(get_db),
):

    person = DeliveryPersonService.update_status(
        db=db,
        delivery_person_id=delivery_person_id,
        status=data.status,
    )

    if person is None:

        raise HTTPException(
            status_code=404,
            detail="Delivery person not found",
        )

    return person


@router.get(
    "/{delivery_person_id}/identity-proof",
)
def get_identity_proof(
    delivery_person_id: int,
    db: Session = Depends(get_db),
):

    person = (
        DeliveryPersonService.get_delivery_person(
            db=db,
            delivery_person_id=delivery_person_id,
        )
    )

    if person is None:

        raise HTTPException(
            status_code=404,
            detail="Delivery person not found",
        )

    project_root = (
        Path(__file__).resolve().parents[2]
    )

    file_path = (
        project_root
        / person.identity_proof_path
    )

    if not file_path.is_file():

        raise HTTPException(
            status_code=404,
            detail="Identity proof file not found",
        )

    return FileResponse(
        path=file_path,
        media_type=person.identity_proof_content_type,
        filename=person.identity_proof_filename,
    )