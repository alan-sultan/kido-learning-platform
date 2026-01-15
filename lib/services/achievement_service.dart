import '../models/child_profile.dart';

/// Simple utility that translates raw profile stats into friendly
/// achievement names. This keeps badge logic in one place so both the
/// profile screen and progress screen stay in sync.
class AchievementService {
  const AchievementService._();

  static final List<_AchievementRule> _rules = [
    _AchievementRule(
      id: 'brave_beginner',
      label: 'Brave Beginner',
      validator: (profile) => profile.totalLessons >= 1,
    ),
    _AchievementRule(
      id: 'curious_cadet',
      label: 'Curious Cadet',
      validator: (profile) => profile.totalLessons >= 5,
    ),
    _AchievementRule(
      id: 'lesson_legend',
      label: 'Lesson Legend',
      validator: (profile) => profile.totalLessons >= 15,
    ),
    _AchievementRule(
      id: 'quiz_wiz',
      label: 'Quiz Wiz',
      validator: (profile) => profile.totalQuizzes >= 3,
    ),
    _AchievementRule(
      id: 'star_collector',
      label: 'Star Collector',
      validator: (profile) => profile.stars >= 25,
    ),
    _AchievementRule(
      id: 'super_nova',
      label: 'Super Nova',
      validator: (profile) => profile.stars >= 75,
    ),
    _AchievementRule(
      id: 'streak_champion',
      label: 'Streak Champion',
      validator: (profile) => profile.streak >= 3,
    ),
    _AchievementRule(
      id: 'level_ace',
      label: 'Level Ace',
      validator: (profile) => profile.level >= 5,
    ),
    _AchievementRule(
      id: 'level_master',
      label: 'Level Master',
      validator: (profile) => profile.level >= 10,
    ),
  ];

  static List<String> deriveBadges(ChildProfile profile) {
    final badges = <String>{};
    badges.addAll(
      profile.badges
          .map((badge) => badge.trim())
          .where((badge) => badge.isNotEmpty),
    );
    for (final rule in _rules) {
      if (rule.validator(profile)) {
        badges.add(rule.label);
      }
    }
    return badges.toList(growable: false);
  }
}

class _AchievementRule {
  const _AchievementRule({
    required this.id,
    required this.label,
    required this.validator,
  });

  final String id;
  final String label;
  final bool Function(ChildProfile profile) validator;
}
