import 'package:flutter_riverpod/flutter_riverpod.dart';

final roleProvider = StateNotifierProvider<RoleNotifier, String?>((ref) => RoleNotifier());
final languageProvider = StateNotifierProvider<LanguageNotifier, String?>((ref) => LanguageNotifier());

class RoleNotifier extends StateNotifier<String?> {
  RoleNotifier() : super(null);
  void setRole(String code) => state = code;
}

class LanguageNotifier extends StateNotifier<String?> {
  LanguageNotifier() : super(null);
  void setLanguage(String code) => state = code;
}