import re

from pydantic import BaseModel, ConfigDict, Field, field_validator


class DeliveryPersonCreate(BaseModel):
    name: str = Field(
        ...,
        min_length=1,
        max_length=150,
    )

    contact_number: str = Field(
        ...,
        min_length=10,
        max_length=10,
    )

    bank_name: str | None = Field(
        default=None,
        max_length=150,
    )

    account_number: str | None = Field(
        default=None,
        min_length=6,
        max_length=18,
    )

    ifsc_code: str | None = Field(
        default=None,
        min_length=11,
        max_length=11,
    )

    aadhaar_number: str | None = Field(
        default=None,
        min_length=12,
        max_length=12,
    )

    pan_card_number: str | None = Field(
        default=None,
        min_length=10,
        max_length=10,
    )

    driving_license: str | None = Field(
        default=None,
        max_length=30,
    )

    @field_validator("name")
    @classmethod
    def validate_name(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError("Name cannot be empty")

        return value

    @field_validator("contact_number")
    @classmethod
    def validate_contact_number(cls, value: str) -> str:
        if not re.fullmatch(r"[06789][0-9]{9}", value):
            raise ValueError(
                "Contact number must contain exactly 10 digits "
                "and start with 0, 6, 7, 8 or 9"
            )

        return value

    @field_validator(
        "bank_name",
        "account_number",
        "ifsc_code",
        "aadhaar_number",
        "pan_card_number",
        "driving_license",
    )
    @classmethod
    def normalize_optional(
        cls,
        value: str | None,
    ) -> str | None:
        if value is None:
            return None

        value = value.strip()

        return value or None

    @field_validator("account_number")
    @classmethod
    def validate_account_number(
        cls,
        value: str | None,
    ) -> str | None:
        if value is not None:
            if not re.fullmatch(r"[0-9]{6,18}", value):
                raise ValueError(
                    "Account number must contain 6 to 18 digits"
                )

        return value

    @field_validator("ifsc_code")
    @classmethod
    def validate_ifsc_code(
        cls,
        value: str | None,
    ) -> str | None:
        if value is not None:
            value = value.upper()

            if not re.fullmatch(
                r"[A-Z]{4}0[A-Z0-9]{6}",
                value,
            ):
                raise ValueError(
                    "Enter a valid 11-character IFSC code"
                )

        return value

    @field_validator("aadhaar_number")
    @classmethod
    def validate_aadhaar_number(
        cls,
        value: str | None,
    ) -> str | None:
        if value is not None:
            if not re.fullmatch(r"[0-9]{12}", value):
                raise ValueError(
                    "Aadhaar number must contain exactly 12 digits"
                )

        return value

    @field_validator("pan_card_number")
    @classmethod
    def validate_pan_card_number(
        cls,
        value: str | None,
    ) -> str | None:
        if value is not None:
            value = value.upper()

            if not re.fullmatch(
                r"[A-Z]{5}[0-9]{4}[A-Z]",
                value,
            ):
                raise ValueError(
                    "Enter a valid PAN number"
                )

        return value

    @field_validator("driving_license")
    @classmethod
    def validate_driving_license(
        cls,
        value: str | None,
    ) -> str | None:
        if value is not None:
            value = value.upper()

            if not re.fullmatch(
                r"[A-Z0-9/-]{5,30}",
                value,
            ):
                raise ValueError(
                    "Enter a valid driving licence number"
                )

        return value


class DeliveryPersonUpdate(DeliveryPersonCreate):
    status: bool


class DeliveryPersonStatusUpdate(BaseModel):
    status: bool


class DeliveryPersonResponse(BaseModel):
    id: int
    name: str
    contact_number: str
    bank_name: str | None
    account_number: str | None
    ifsc_code: str | None
    aadhaar_number: str | None
    pan_card_number: str | None
    driving_license: str | None

    identity_proof_filename: str
    identity_proof_content_type: str
    identity_proof_size: int

    status: bool

    model_config = ConfigDict(
        from_attributes=True,
    )