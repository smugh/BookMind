import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookmind/core/localization/app_strings.dart';
import 'package:bookmind/core/services/app_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettings and Localization Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Default AppSettingsState has null custom images and language id', () {
      const state = AppSettingsState();
      expect(state.coverImagePath, isNull);
      expect(state.profileImagePath, isNull);
      expect(state.language, 'id');
    });

    test('AppSettingsNotifier sets and persists language', () async {
      final notifier = AppSettingsNotifier();
      expect(notifier.state.language, 'id');

      await notifier.setLanguage('en');
      expect(notifier.state.language, 'en');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings_language'), 'en');

      await notifier.setLanguage('id');
      expect(notifier.state.language, 'id');
    });

    test('AppSettingsNotifier handles resetProfileImage and resetCoverImage', () async {
      final notifier = AppSettingsNotifier();
      await notifier.resetProfileImage();
      expect(notifier.state.profileImagePath, isNull);

      await notifier.resetCoverImage();
      expect(notifier.state.coverImagePath, isNull);
    });

    test('AppStrings provides correct translations for id and en', () {
      expect(AppStrings.tr('created_by', 'id'), 'Created by smugh-tech');
      expect(AppStrings.tr('created_by', 'en'), 'Created by smugh-tech');
      expect(AppStrings.tr('under_development', 'id'), 'Under Development');
      expect(AppStrings.tr('under_development', 'en'), 'Under Development');

      expect(AppStrings.tr('profile_title', 'id'), 'Profil Saya');
      expect(AppStrings.tr('profile_title', 'en'), 'My Profile');

      expect(AppStrings.tr('appearance_settings', 'id'), 'Pengaturan Tampilan');
      expect(AppStrings.tr('appearance_settings', 'en'), 'Appearance Settings');

      expect(AppStrings.tr('export_notes', 'id'), 'Ekspor Catatan');
      expect(AppStrings.tr('export_notes', 'en'), 'Export Notes');
    });
  });
}
