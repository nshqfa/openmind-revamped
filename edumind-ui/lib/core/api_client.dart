import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class ApiException implements Exception {
  ApiException(this.status, this.code, this.message);
  final int status;
  final String code;
  final String message;
  @override
  String toString() => '$code: $message';
}

/// REST client for the EduMind backend (/api/v1).
class Api {
  static String get _base => Session.instance.baseUrl;

  static Map<String, String> _headers({bool auth = true, bool withBody = false}) => {
        if (withBody) 'content-type': 'application/json',
        if (auth && Session.instance.token != null)
          'authorization': 'Bearer ${Session.instance.token}',
      };

  static Future<dynamic> _decode(http.Response res) async {
    if (res.statusCode == 204) return null;
    final body = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 400) {
      final err = (body is Map && body['error'] is Map) ? body['error'] as Map : null;
      throw ApiException(res.statusCode, (err?['code'] as String?) ?? 'HTTP_${res.statusCode}',
          (err?['message'] as String?) ?? 'request failed');
    }
    return body;
  }

  static Future<dynamic> get(String path) async =>
      _decode(await http
          .get(Uri.parse('$_base$path'), headers: _headers())
          .timeout(const Duration(seconds: 20)));

  static Future<dynamic> post(String path, [Object? body, bool auth = true]) async =>
      _decode(await http
          .post(Uri.parse('$_base$path'),
              headers: _headers(auth: auth, withBody: body != null),
              body: body == null ? null : jsonEncode(body))
          .timeout(const Duration(seconds: 30)));

  static Future<dynamic> patch(String path, Object body) async =>
      _decode(await http
          .patch(Uri.parse('$_base$path'),
              headers: _headers(withBody: true), body: jsonEncode(body))
          .timeout(const Duration(seconds: 20)));

  static Future<dynamic> delete(String path) async =>
      _decode(await http
          .delete(Uri.parse('$_base$path'), headers: _headers())
          .timeout(const Duration(seconds: 20)));

  // ---- typed helpers -----------------------------------------------------

  static Future<Map<String, dynamic>?> health() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/v1/health'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createStudent(Map<String, dynamic> body) async =>
      (await post('/api/v1/students', body, false)) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> me() async =>
      (await get('/api/v1/students/me')) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> patchMe(Map<String, dynamic> body) async =>
      (await patch('/api/v1/students/me', body)) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> learnProgress() async =>
      (await get('/api/v1/learn/progress')) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> putLearnProgress(String pathId, String experienceId) async =>
      (await _decode(await http
          .put(Uri.parse('$_base/api/v1/learn/progress'),
              headers: _headers(withBody: true),
              body: jsonEncode({'pathId': pathId, 'experienceId': experienceId}))
          .timeout(const Duration(seconds: 20)))) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> verifyTool(
    String toolId,
    Map<String, dynamic> data,
    Map<String, dynamic> answer, {
    Map<String, dynamic>? evidence,
  }) async =>
      (await post('/api/v1/tools/$toolId/verify', {
        'data': data,
        'answer': answer,
        if (evidence != null) 'evidence': evidence,
      })) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> learnEvidence() async =>
      (await get('/api/v1/learn/evidence')) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> postLearnEvidence(
          List<Map<String, dynamic>> events) async =>
      (await post('/api/v1/learn/evidence', {'events': events}))
          as Map<String, dynamic>;

  static Future<Map<String, dynamic>> createGame(Map<String, dynamic> body) async =>
      (await post('/api/v1/games', body)) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> askTutor(Map<String, dynamic> body) async =>
      (await post('/api/v1/tutor/messages', body)) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> tutorConversation(String id) async =>
      (await get('/api/v1/tutor/conversations/$id')) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> gameStatus(String id) async =>
      (await get('/api/v1/games/$id')) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> waitForSpec(String id,
      {Duration interval = const Duration(seconds: 2), Duration timeout = const Duration(seconds: 90)}) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = await gameStatus(id);
      if (status['status'] == 'ready') {
        return (await get('/api/v1/games/$id/spec')) as Map<String, dynamic>;
      }
      if (status['status'] == 'failed') {
        throw ApiException(410, 'GENERATION_FAILED', (status['error'] as String?) ?? 'generation failed');
      }
      await Future<void>.delayed(interval);
    }
    throw ApiException(408, 'TIMEOUT', 'generation timed out');
  }

  // ---- curriculum helpers ------------------------------------------------

  static Future<List<Map<String, dynamic>>> getGrades() async {
    final res = await get('/api/v1/curriculum/grades') as Map;
    return (res['items'] as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getSubjectsByGrade(String gradeId) async {
    final res = await get('/api/v1/curriculum/grades/$gradeId/subjects') as Map;
    return (res['items'] as List).cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> getLearningPathWithNodes(String pathId) async {
    return await get('/api/v1/curriculum/learning-paths/$pathId?withNodes=true') as Map<String, dynamic>;
  }
}