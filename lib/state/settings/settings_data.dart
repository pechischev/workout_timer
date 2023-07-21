import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_data.freezed.dart';

part 'settings_data.g.dart';

@freezed
class SettingsData with _$SettingsData {
  const SettingsData._();

  const factory SettingsData({
    @Default(5) int countSets,
    @Default(3) int countRounds,
    @Default(Duration(seconds: 15)) Duration timeRest,
    @Default(Duration(seconds: 45)) Duration timeWork,
  }) = _SettingsData;

  factory SettingsData.fromJson(Map<String, Object?> json) =>
      _$SettingsDataFromJson(json);
}
