from pathlib import Path
from uuid import uuid4

from fastapi import UploadFile

from app.models.delivery_person import DeliveryPerson
from app.repositories.delivery_person import DeliveryPersonRepository
from app.schemas.delivery_person import (
    DeliveryPersonCreate,
    DeliveryPersonUpdate,
)


MAX_IDENTITY_PROOF_SIZE = 10 * 1024 * 1024


ALLOWED_EXTENSIONS = {
    ".pdf": "application/pdf",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
}


ALLOWED_CONTENT_TYPES = {
    "application/pdf",
    "image/jpeg",
    "image/png",
}


UPLOAD_ROOT = (
    Path(__file__).resolve().parents[2]
    / "uploads"
    / "delivery_persons"
)


def _get_extension(filename: str | None) -> str:
    if not filename:
        raise ValueError(
            "Identity proof file name is missing"
        )

    extension = Path(filename).suffix.lower()

    if extension not in ALLOWED_EXTENSIONS:
        raise ValueError(
            "Identity proof must be PDF, JPG, JPEG or PNG"
        )

    return extension


async def _save_identity_proof(
    upload: UploadFile,
) -> tuple[str, str, int]:

    extension = _get_extension(
        upload.filename
    )

    if upload.content_type not in ALLOWED_CONTENT_TYPES:
        raise ValueError(
            "Unsupported identity proof file type"
        )

    UPLOAD_ROOT.mkdir(
        parents=True,
        exist_ok=True,
    )

    stored_name = (
        f"{uuid4().hex}{extension}"
    )

    destination = (
        UPLOAD_ROOT / stored_name
    )

    total_size = 0
    first_chunk = b""

    try:
        with destination.open("wb") as output:

            while True:
                chunk = await upload.read(
                    1024 * 1024
                )

                if not chunk:
                    break

                if not first_chunk:
                    first_chunk = chunk[:16]

                total_size += len(chunk)

                if total_size > MAX_IDENTITY_PROOF_SIZE:
                    raise ValueError(
                        "Identity proof file must not exceed 10 MB"
                    )

                output.write(chunk)

        if total_size == 0:
            raise ValueError(
                "Identity proof file cannot be empty"
            )

        # Basic PDF signature validation.
        if (
            extension == ".pdf"
            and not first_chunk.startswith(b"%PDF")
        ):
            raise ValueError(
                "The selected file is not a valid PDF"
            )

        # Basic JPG/JPEG signature validation.
        if (
            extension in {".jpg", ".jpeg"}
            and not first_chunk.startswith(b"\xff\xd8\xff")
        ):
            raise ValueError(
                "The selected file is not a valid JPG/JPEG image"
            )

        # Basic PNG signature validation.
        if (
            extension == ".png"
            and not first_chunk.startswith(
                b"\x89PNG\r\n\x1a\n"
            )
        ):
            raise ValueError(
                "The selected file is not a valid PNG image"
            )

        relative_path = str(
            Path("uploads")
            / "delivery_persons"
            / stored_name
        ).replace("\\", "/")

        return (
            stored_name,
            relative_path,
            total_size,
        )

    except Exception:
        destination.unlink(
            missing_ok=True
        )
        raise


def _delete_identity_proof(
    relative_path: str | None,
) -> None:

    if not relative_path:
        return

    project_root = (
        Path(__file__).resolve().parents[2]
    )

    file_path = (
        project_root / relative_path
    )

    try:
        file_path.unlink(
            missing_ok=True
        )
    except OSError:
        pass


class DeliveryPersonService:

    @staticmethod
    def get_delivery_persons(
        db,
        include_inactive: bool = False,
    ):
        return DeliveryPersonRepository.get_all(
            db=db,
            include_inactive=include_inactive,
        )

    @staticmethod
    def get_delivery_person(
        db,
        delivery_person_id: int,
    ):
        return DeliveryPersonRepository.get_by_id(
            db=db,
            delivery_person_id=delivery_person_id,
        )

    @staticmethod
    async def create_delivery_person(
        db,
        data: DeliveryPersonCreate,
        identity_proof: UploadFile,
    ):

        (
            stored_name,
            relative_path,
            file_size,
        ) = await _save_identity_proof(
            identity_proof
        )

        try:
            person = DeliveryPerson(
                name=data.name,
                contact_number=data.contact_number,
                bank_name=data.bank_name,
                account_number=data.account_number,
                ifsc_code=data.ifsc_code,
                aadhaar_number=data.aadhaar_number,
                pan_card_number=data.pan_card_number,
                driving_license=data.driving_license,
                identity_proof_filename=(
                    identity_proof.filename
                    or stored_name
                ),
                identity_proof_path=relative_path,
                identity_proof_content_type=(
                    identity_proof.content_type
                    or "application/octet-stream"
                ),
                identity_proof_size=file_size,
                status=True,
            )

            return DeliveryPersonRepository.create(
                db,
                person,
            )

        except Exception:
            db.rollback()

            _delete_identity_proof(
                relative_path
            )

            raise

    @staticmethod
    async def update_delivery_person(
        db,
        delivery_person_id: int,
        data: DeliveryPersonUpdate,
        identity_proof: UploadFile | None = None,
    ):

        person = (
            DeliveryPersonRepository.get_by_id(
                db=db,
                delivery_person_id=delivery_person_id,
            )
        )

        if person is None:
            return None

        old_path = person.identity_proof_path
        new_path = None

        if identity_proof is not None:
            (
                stored_name,
                relative_path,
                file_size,
            ) = await _save_identity_proof(
                identity_proof
            )

            new_path = relative_path

            person.identity_proof_filename = (
                identity_proof.filename
                or stored_name
            )

            person.identity_proof_path = (
                relative_path
            )

            person.identity_proof_content_type = (
                identity_proof.content_type
                or "application/octet-stream"
            )

            person.identity_proof_size = (
                file_size
            )

        person.name = data.name
        person.contact_number = (
            data.contact_number
        )
        person.bank_name = data.bank_name
        person.account_number = (
            data.account_number
        )
        person.ifsc_code = data.ifsc_code
        person.aadhaar_number = (
            data.aadhaar_number
        )
        person.pan_card_number = (
            data.pan_card_number
        )
        person.driving_license = (
            data.driving_license
        )
        person.status = data.status

        try:
            updated = (
                DeliveryPersonRepository.update(
                    db,
                    person,
                )
            )

            if (
                new_path
                and old_path
                and old_path != new_path
            ):
                _delete_identity_proof(
                    old_path
                )

            return updated

        except Exception:
            db.rollback()

            if new_path:
                _delete_identity_proof(
                    new_path
                )

            raise

    @staticmethod
    def update_status(
        db,
        delivery_person_id: int,
        status: bool,
    ):

        person = (
            DeliveryPersonRepository.get_by_id(
                db=db,
                delivery_person_id=delivery_person_id,
            )
        )

        if person is None:
            return None

        return DeliveryPersonRepository.update_status(
            db=db,
            delivery_person=person,
            status=status,
        )