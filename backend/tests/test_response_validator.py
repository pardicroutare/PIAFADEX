import pytest

from app.services.response_validator import validate_analyze_payload


def test_validate_payload_normalizes_spaces():
    payload = {
        "success": True,
        "result_type": "bird_identified",
        "bird": {
            "common_name": "  Huppe   fasciée  ",
            "scientific_name": " Upupa epops ",
            "confidence_label": "probable",
            "discovery_level": 3,
            "fun_type_label": "  Piaf-Crête  ",
            "habitat_short": " vergers   et jardins ",
            "diet_short": " insectes ",
            "professor_commentary_text": " commentaire   test ",
            "alternatives": [
                {"common_name": "Moineau", "scientific_name": "Passer domesticus"},
                {"common_name": "Merle", "scientific_name": "Turdus merula"},
                {"common_name": "Rouge-gorge", "scientific_name": "Erithacus rubecula"},
            ],
        },
    }

    out = validate_analyze_payload(payload)

    assert out["bird"]["common_name"] == "Huppe fasciée"
    assert out["bird"]["fun_type_label"] == "Piaf-Crête"


def test_validate_payload_rejects_empty_after_trim():
    payload = {
        "success": True,
        "result_type": "image_unusable",
        "issue": {
            "code": "image_too_dark",
            "user_reason": "   ",
            "professor_commentary_text": "trop sombre",
        },
    }

    with pytest.raises(ValueError):
        validate_analyze_payload(payload)
