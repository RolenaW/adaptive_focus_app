// Model-like class to hold one AI recommendation result
class AiFocusDjRecommendation {
  final String mixName;
  final bool rainEnabled;
  final bool cafeEnabled;
  final bool whiteNoiseEnabled;
  final bool natureEnabled;
  final bool instrumentalEnabled;
  final int recommendedWorkDuration;
  final int recommendedBreakDuration;
  final String explanation;

  const AiFocusDjRecommendation({
    required this.mixName,
    required this.rainEnabled,
    required this.cafeEnabled,
    required this.whiteNoiseEnabled,
    required this.natureEnabled,
    required this.instrumentalEnabled,
    required this.recommendedWorkDuration,
    required this.recommendedBreakDuration,
    required this.explanation,
  });
}

class AiFocusDjHelper {
  // Rule-based AI helper that returns a recommendation
  static AiFocusDjRecommendation getRecommendation({
    required String? mood,
    required String? taskType,
    required int energyLevel,
  }) {
    // Safe default if required details are missing
    if (mood == null || taskType == null) {
      return const AiFocusDjRecommendation(
        mixName: 'Balanced Focus Mix',
        rainEnabled: true,
        cafeEnabled: false,
        whiteNoiseEnabled: true,
        natureEnabled: false,
        instrumentalEnabled: false,
        recommendedWorkDuration: 25,
        recommendedBreakDuration: 5,
        explanation:
            'This balanced mix is a safe starting point when session details are incomplete.',
      );
    }

    // Focused + Coding
    if (mood == 'Focused' && taskType == 'Coding') {
      return AiFocusDjRecommendation(
        mixName: 'Deep Coding Mix',
        rainEnabled: false,
        cafeEnabled: false,
        whiteNoiseEnabled: true,
        natureEnabled: false,
        instrumentalEnabled: true,
        recommendedWorkDuration: energyLevel >= 7 ? 45 : 25,
        recommendedBreakDuration: energyLevel >= 7 ? 10 : 5,
        explanation:
            'Suggested because focused technical work often benefits from steady masking noise and light instrumental support.',
      );
    }

    // Calm + Reading
    if (mood == 'Calm' && taskType == 'Reading') {
      return const AiFocusDjRecommendation(
        mixName: 'Quiet Reading Mix',
        rainEnabled: true,
        cafeEnabled: false,
        whiteNoiseEnabled: false,
        natureEnabled: true,
        instrumentalEnabled: false,
        recommendedWorkDuration: 25,
        recommendedBreakDuration: 5,
        explanation:
            'Suggested because calm reading sessions often work well with soft rain and nature ambience.',
      );
    }

    // Stressed mood
    if (mood == 'Stressed') {
      return const AiFocusDjRecommendation(
        mixName: 'Recovery Focus Mix',
        rainEnabled: true,
        cafeEnabled: false,
        whiteNoiseEnabled: false,
        natureEnabled: true,
        instrumentalEnabled: false,
        recommendedWorkDuration: 25,
        recommendedBreakDuration: 10,
        explanation:
            'Suggested because lower-pressure soundscapes and a longer break can help reduce overwhelm.',
      );
    }

    // Writing
    if (taskType == 'Writing') {
      return AiFocusDjRecommendation(
        mixName: 'Creative Writing Mix',
        rainEnabled: true,
        cafeEnabled: false,
        whiteNoiseEnabled: false,
        natureEnabled: false,
        instrumentalEnabled: true,
        recommendedWorkDuration: energyLevel >= 6 ? 45 : 25,
        recommendedBreakDuration: energyLevel >= 6 ? 10 : 5,
        explanation:
            'Suggested because writing often benefits from gentle ambience with light instrumental support.',
      );
    }

    // High energy
    if (energyLevel >= 8) {
      return const AiFocusDjRecommendation(
        mixName: 'High Energy Focus Mix',
        rainEnabled: false,
        cafeEnabled: true,
        whiteNoiseEnabled: true,
        natureEnabled: false,
        instrumentalEnabled: false,
        recommendedWorkDuration: 45,
        recommendedBreakDuration: 10,
        explanation:
            'Suggested because high energy can support a longer work block with stronger background masking.',
      );
    }

    // Low energy
    if (energyLevel <= 4) {
      return const AiFocusDjRecommendation(
        mixName: 'Low Energy Reset Mix',
        rainEnabled: true,
        cafeEnabled: false,
        whiteNoiseEnabled: false,
        natureEnabled: true,
        instrumentalEnabled: false,
        recommendedWorkDuration: 25,
        recommendedBreakDuration: 10,
        explanation:
            'Suggested because lower energy often responds better to softer sounds and more recovery time.',
      );
    }

    // General fallback
    return const AiFocusDjRecommendation(
      mixName: 'Balanced Productivity Mix',
      rainEnabled: true,
      cafeEnabled: false,
      whiteNoiseEnabled: true,
      natureEnabled: false,
      instrumentalEnabled: false,
      recommendedWorkDuration: 25,
      recommendedBreakDuration: 5,
      explanation:
          'Suggested as a general-purpose mix for balanced focus and moderate energy.',
    );
  }
}