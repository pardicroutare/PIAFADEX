from enum import Enum
from typing import Annotated, List, Literal, Union

from pydantic import BaseModel, Field, StringConstraints, model_validator

TShort = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=160)]


class ConfidenceLabel(str, Enum):
    quasi_certain = "quasi certain"
    fort_probable = "fort probable"
    probable = "probable"
    incertain = "incertain"
    hautement_incertain = "hautement incertain"


class AlternativeBird(BaseModel):
    common_name: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=120)]
    scientific_name: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=160)]


class BirdResult(BaseModel):
    common_name: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=120)]
    scientific_name: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=160)]
    confidence_label: ConfidenceLabel
    discovery_level: int = Field(ge=1, le=6)
    fun_type_label: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=40)]
    habitat_short: TShort
    diet_short: TShort
    professor_commentary_text: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=700)]
    alternatives: List[AlternativeBird] = Field(min_length=3, max_length=3)


class IssueResult(BaseModel):
    code: Literal[
        "no_bird_visible",
        "bird_too_small",
        "image_too_blurry",
        "image_too_dark",
        "multiple_birds_ambiguous",
        "bird_partially_out_of_frame",
        "fictional_bird_object",
        "unsupported_image",
    ]
    user_reason: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=200)]
    professor_commentary_text: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=300)]


class AnalyzeBirdSuccessBirdIdentified(BaseModel):
    success: Literal[True]
    result_type: Literal["bird_identified"]
    bird: BirdResult

    @model_validator(mode="after")
    def validate_alternatives_unique(self):
        main_name = (self.bird.common_name.strip().lower(), self.bird.scientific_name.strip().lower())
        for alt in self.bird.alternatives:
            if (alt.common_name.strip().lower(), alt.scientific_name.strip().lower()) == main_name:
                raise ValueError("alternative cannot be identical to main species")
        return self


class AnalyzeBirdSuccessImageUnusable(BaseModel):
    success: Literal[True]
    result_type: Literal["image_unusable"]
    issue: IssueResult


AnalyzeBirdResponse = Union[AnalyzeBirdSuccessBirdIdentified, AnalyzeBirdSuccessImageUnusable]


class ApiErrorBody(BaseModel):
    code: Literal[
        "bad_request",
        "unsupported_image",
        "file_too_large",
        "upstream_timeout",
        "upstream_invalid_json",
        "internal_error",
    ]
    message: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=300)]


class ApiErrorResponse(BaseModel):
    success: Literal[False]
    error: ApiErrorBody


class GenerateAudioRequest(BaseModel):
    common_name: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=120)]
    scientific_name: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=160)]
    fun_type_label: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=40)]
    habitat_short: TShort
    diet_short: TShort
    professor_commentary_text: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=700)]
