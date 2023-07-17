import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_data.freezed.dart';

@freezed
class SettingsData with _$SettingsData {
  const SettingsData._();

  const factory SettingsData({
    @Default(4) int countSets,
    @Default(5) int countRounds,
    @Default(Duration(seconds: 10)) Duration timeRest,
    @Default(Duration(seconds: 30)) Duration timeWork,
  }) = _SettingsData;

}