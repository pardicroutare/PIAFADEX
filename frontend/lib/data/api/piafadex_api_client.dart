import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:dio/dio.dart';

import '../models/analyze_bird_response.dart';

class PiafadexApiClient {
  PiafadexApiClient({required String baseUrl}) : _dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15)));

  final Dio _dio;

  Future<AnalyzeBirdResponse> analyzeBird({required File imageFile, Map<String, dynamic>? clientContext}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
      if (clientContext != null) 'client_context': jsonEncode(clientContext),
    });

    final response = await _dio.post<Map<String, dynamic>>('/analyze-bird', data: formData);
    return AnalyzeBirdResponse.fromJson(response.data ?? const {});
  }

  Future<Uint8List> generateAudio({
    required String commonName,
    required String scientificName,
    required String funTypeLabel,
    required String habitatShort,
    required String dietShort,
    required String professorCommentaryText,
  }) async {
    final response = await _dio.post<List<int>>(
      '/generate-audio',
      data: {
        'common_name': commonName,
        'scientific_name': scientificName,
        'fun_type_label': funTypeLabel,
        'habitat_short': habitatShort,
        'diet_short': dietShort,
        'professor_commentary_text': professorCommentaryText,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }
}
