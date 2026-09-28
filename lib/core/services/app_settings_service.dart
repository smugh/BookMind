import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsState {
  final String? coverImagePath;
  final String? profileImagePath;
  final String language; // 'id' or 'en'

  const AppSettingsState({
    this.coverImagePath,
    this.profileImagePath,
    this.language = 'id',
  });

  AppSettingsState copyWith({
    String? Function()? coverImagePath,
    String? Function()? profileImagePath,
    String? language,
  }) {
    return AppSettingsState(
      coverImagePath:
          coverImagePath != null ? coverImagePath() : this.coverImagePath,
      profileImagePath:
          profileImagePath != null ? profileImagePath() : this.profileImagePath,
      language: language ?? this.language,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  static const _keyCover = 'settings_cover_image_path';
  static const _keyProfile = 'settings_profile_image_path';
  static const _keyLanguage = 'settings_language';

  AppSettingsNotifier() : super(const AppSettingsState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coverPath = prefs.getString(_keyCover);
      final profilePath = prefs.getString(_keyProfile);
      final language = prefs.getString(_keyLanguage) ?? 'id';

      // Validate files if paths exist
      String? validCover;
      if (coverPath != null && coverPath.isNotEmpty) {
        if (kIsWeb || File(coverPath).existsSync()) {
          validCover = coverPath;
        }
      }

      String? validProfile;
      if (profilePath != null && profilePath.isNotEmpty) {
        if (kIsWeb || File(profilePath).existsSync()) {
          validProfile = profilePath;
        }
      }

      state = AppSettingsState(
        coverImagePath: validCover,
        profileImagePath: validProfile,
        language: language,
      );
    } catch (e) {
      debugPrint('Error loading AppSettings: $e');
    }
  }

  Future<bool> pickAndSetProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return false;
      final file = result.files.first;

      String? finalPath;
      if (kIsWeb) {
        finalPath = file.name;
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        final imgDir = Directory(p.join(docsDir.path, 'user_images'));
        if (!await imgDir.exists()) {
          await imgDir.create(recursive: true);
        }
        final ext = file.extension ?? 'jpg';
        final savedFile = File(
            p.join(imgDir.path, 'profile_${DateTime.now().millisecondsSinceEpoch}.$ext'));
        if (file.bytes != null) {
          await savedFile.writeAsBytes(file.bytes!);
        } else if (file.path != null) {
          await File(file.path!).copy(savedFile.path);
        }
        finalPath = savedFile.path;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyProfile, finalPath);
      state = state.copyWith(profileImagePath: () => finalPath);
      return true;
    } catch (e) {
      debugPrint('Error picking profile image: $e');
    }
    return false;
  }

  Future<void> resetProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProfile);
    state = state.copyWith(profileImagePath: () => null);
  }

  Future<bool> pickAndSetCoverImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return false;
      final file = result.files.first;

      String? finalPath;
      if (kIsWeb) {
        finalPath = file.name;
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        final imgDir = Directory(p.join(docsDir.path, 'user_images'));
        if (!await imgDir.exists()) {
          await imgDir.create(recursive: true);
        }
        final ext = file.extension ?? 'jpg';
        final savedFile = File(
            p.join(imgDir.path, 'cover_${DateTime.now().millisecondsSinceEpoch}.$ext'));
        if (file.bytes != null) {
          await savedFile.writeAsBytes(file.bytes!);
        } else if (file.path != null) {
          await File(file.path!).copy(savedFile.path);
        }
        finalPath = savedFile.path;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCover, finalPath);
      state = state.copyWith(coverImagePath: () => finalPath);
      return true;
    } catch (e) {
      debugPrint('Error picking cover image: $e');
    }
    return false;
  }

  Future<void> resetCoverImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCover);
    state = state.copyWith(coverImagePath: () => null);
  }

  Future<void> setLanguage(String lang) async {
    if (lang != 'id' && lang != 'en') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
    state = state.copyWith(language: lang);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  return AppSettingsNotifier();
});
