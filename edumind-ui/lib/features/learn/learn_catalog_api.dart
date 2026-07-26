import '../../core/api_client.dart';
import 'learn_models.dart';

/// Fetches the learning catalog from the seeded database via the backend API,
/// mapping the DB's Grade → Subject → LearningPath → PathNode tree into the
/// LearnCatalog models the UI already renders.
class LearnCatalogApiLoader {
  static Future<List<LearnCatalog>> fetchFromDatabase({
    required int grade,
    String? language,
  }) async {
//     print('>>> grade: $grade, language: $language');
// print('>>> baseUrl: ${Api.baseUrl}');
    try {
      // 1. Find the matching grade
      final gradesRes = await Api.get('/api/v1/curriculum/grades') as Map;
      final grades = (gradesRes['items'] as List).cast<Map<String, dynamic>>();
      final targetGrade = grades.firstWhere(
        (g) => (g['index'] as num).toInt() == grade,
        orElse: () => <String, dynamic>{},
      );
      if (targetGrade.isEmpty) return [];

      // 2. Get subjects for this grade
      final subjectsRes =
          await Api.get('/api/v1/curriculum/grades/${targetGrade['id']}/subjects') as Map;
      final subjects =
          (subjectsRes['items'] as List).cast<Map<String, dynamic>>();

      final List<LearnCatalog> catalogs = [];

      for (final subject in subjects) {
        // 3. Get learning paths for each subject
        final subjectRes = await Api.get(
            '/api/v1/curriculum/subjects/${subject['id']}?withPaths=true') as Map;
        final paths =
            ((subjectRes['learningPaths'] as List?) ?? []).cast<Map<String, dynamic>>();

        for (final path in paths) {
          // 4. Get path nodes for each learning path
          final pathRes = await Api.get(
              '/api/v1/curriculum/learning-paths/${path['id']}?withNodes=true') as Map;
          final nodes =
              ((pathRes['pathNodes'] as List?) ?? []).cast<Map<String, dynamic>>();

          // Map PathNodes → LearnExperiences
          final experiences = nodes.map((node) {
            final isAr = language == 'ar';
            return LearnExperience(
              id: node['id'] as String,
              title: (isAr && node['titleAr'] != null)
                  ? node['titleAr'] as String
                  : node['title'] as String,
              subtitle: (node['topic'] as String?) ?? '',
              ready: node['nodeStatus'] == 'available' ||
                  node['nodeStatus'] == 'in_progress',
              steps: [
                LearnStep(
                  kind: LearnStepKind.scene,
                  title: (isAr && node['titleAr'] != null)
                      ? node['titleAr'] as String
                      : node['title'] as String,
                  body: (node['topic'] as String?) ?? '',
                ),
              ],
            );
          }).toList();

          catalogs.add(LearnCatalog(
            language: language ?? 'ar',
            subject: subject['title'] as String,
            grade: grade,
            paths: [
              LearnPath(
                id: path['id'] as String,
                title: path['name'] as String,
                tagline: (path['description'] as String?) ?? '',
                emoji: '⭐',
                colorHex: '#1CB0F6',
                experiences: experiences,
              ),
            ],
          ));
        }
      }
      return catalogs;
    } catch (e) {
      // ignore: avoid_print
      print('LearnCatalogApiLoader: failed to fetch from DB: $e');
      return [];
    }
  }
}