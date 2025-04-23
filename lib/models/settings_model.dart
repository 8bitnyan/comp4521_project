class Settings {
  final bool darkMode;
  final bool notificationsEnabled;

  Settings({
    required this.darkMode,
    required this.notificationsEnabled,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      darkMode: json['dark_mode'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
    };
  }

  Settings copyWith({bool? darkMode, bool? notificationsEnabled}) {
    return Settings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
