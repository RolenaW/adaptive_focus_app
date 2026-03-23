class FocusAIService {
  static Map<String, dynamic> generateRecommendation({
    required String mood,
    required String task,
    required int energy,
  }) {
    bool rain = false;
    bool cafe = false;
    bool whiteNoise = false;
    bool nature = false;
    bool instrumental = false;
    double volume = 0.5;
    String sessionType = "Balanced Focus";

    if (mood == "Calm") {
      rain = true;
      nature = true;
      volume = 0.4;
      sessionType = "Deep Calm Focus";
    } else if (mood == "Stressed") {
      rain = true;
      whiteNoise = true;
      volume = 0.3;
      sessionType = "Stress Recovery";
    } else if (mood == "Tired") {
      cafe = true;
      instrumental = true;
      volume = 0.6;
      sessionType = "Energy Boost";
    }

    if (task == "Coding") {
      whiteNoise = true;
      instrumental = true;
    } else if (task == "Reading") {
      rain = true;
    }

    if (energy >= 7) volume += 0.1;
    if (energy <= 3) volume -= 0.1;

    return {
      'rain': rain,
      'cafe': cafe,
      'whiteNoise': whiteNoise,
      'nature': nature,
      'instrumental': instrumental,
      'volume': volume.clamp(0.2, 1.0),
      'sessionType': sessionType,
    };
  }
}