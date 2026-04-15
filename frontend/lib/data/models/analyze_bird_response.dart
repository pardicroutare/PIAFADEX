class AnalyzeBirdResponse {
  AnalyzeBirdResponse({
    required this.success,
    required this.resultType,
    this.bird,
    this.issue,
  });

  factory AnalyzeBirdResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeBirdResponse(
      success: json['success'] == true,
      resultType: json['result_type'] as String? ?? '',
      bird: json['bird'] is Map<String, dynamic>
          ? BirdResult.fromJson(json['bird'] as Map<String, dynamic>)
          : null,
      issue: json['issue'] is Map<String, dynamic>
          ? IssueResult.fromJson(json['issue'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool success;
  final String resultType;
  final BirdResult? bird;
  final IssueResult? issue;
}

class BirdResult {
  BirdResult({
    required this.commonName,
    required this.scientificName,
    required this.confidenceLabel,
    required this.discoveryLevel,
    required this.funTypeLabel,
    required this.habitatShort,
    required this.dietShort,
    required this.professorCommentaryText,
    required this.alternatives,
  });

  factory BirdResult.fromJson(Map<String, dynamic> json) {
    return BirdResult(
      commonName: json['common_name'] as String? ?? '',
      scientificName: json['scientific_name'] as String? ?? '',
      confidenceLabel: json['confidence_label'] as String? ?? '',
      discoveryLevel: json['discovery_level'] as int? ?? 1,
      funTypeLabel: json['fun_type_label'] as String? ?? '',
      habitatShort: json['habitat_short'] as String? ?? '',
      dietShort: json['diet_short'] as String? ?? '',
      professorCommentaryText: json['professor_commentary_text'] as String? ?? '',
      alternatives: (json['alternatives'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AlternativeBird.fromJson)
          .toList(),
    );
  }

  final String commonName;
  final String scientificName;
  final String confidenceLabel;
  final int discoveryLevel;
  final String funTypeLabel;
  final String habitatShort;
  final String dietShort;
  final String professorCommentaryText;
  final List<AlternativeBird> alternatives;
}

class AlternativeBird {
  AlternativeBird({required this.commonName, required this.scientificName});

  factory AlternativeBird.fromJson(Map<String, dynamic> json) {
    return AlternativeBird(
      commonName: json['common_name'] as String? ?? '',
      scientificName: json['scientific_name'] as String? ?? '',
    );
  }

  final String commonName;
  final String scientificName;
}

class IssueResult {
  IssueResult({required this.code, required this.userReason, required this.professorCommentaryText});

  factory IssueResult.fromJson(Map<String, dynamic> json) {
    return IssueResult(
      code: json['code'] as String? ?? '',
      userReason: json['user_reason'] as String? ?? '',
      professorCommentaryText: json['professor_commentary_text'] as String? ?? '',
    );
  }

  final String code;
  final String userReason;
  final String professorCommentaryText;
}
