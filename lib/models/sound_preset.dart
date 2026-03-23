class SoundPreset {
  final int? id;
  final String name;
  final bool rain;
  final bool cafe;
  final bool whiteNoise;
  final bool nature;
  final bool instrumental;
  final double volume;
  final String createdAt;

  SoundPreset({
    this.id,
    required this.name,
    required this.rain,
    required this.cafe,
    required this.whiteNoise,
    required this.nature,
    required this.instrumental,
    required this.volume,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'preset_name': name,
      'rain_enabled': rain ? 1 : 0,
      'cafe_enabled': cafe ? 1 : 0,
      'white_noise_enabled': whiteNoise ? 1 : 0,
      'nature_enabled': nature ? 1 : 0,
      'instrumental_enabled': instrumental ? 1 : 0,
      'master_volume': volume,
      'created_at': createdAt,
    };
  }

  factory SoundPreset.fromMap(Map<String, dynamic> map) {
    return SoundPreset(
      id: map['id'],
      name: map['preset_name'],
      rain: map['rain_enabled'] == 1,
      cafe: map['cafe_enabled'] == 1,
      whiteNoise: map['white_noise_enabled'] == 1,
      nature: map['nature_enabled'] == 1,
      instrumental: map['instrumental_enabled'] == 1,
      volume: map['master_volume'],
      createdAt: map['created_at'],
    );
  }
}