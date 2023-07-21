import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'settings_data.dart';

part 'settings_bloc.freezed.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const SettingsEvent._();

  @literal
  const factory SettingsEvent.update({
    required SettingsData data,
  }) = _UpdateSettingsEvent;
}

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsData> {
  SettingsBloc() : super(const SettingsData()) {
    on<_UpdateSettingsEvent>(_update);
  }

  @override
  SettingsData? fromJson(Map<String, dynamic> json) {
    return SettingsData.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingsData state) {
    return state.toJson();
  }

  void _update(_UpdateSettingsEvent event, Emitter<SettingsData> emitter) {
    final data = event.data;
    emitter(state.copyWith(
      countSets: data.countSets,
      countRounds: data.countRounds,
      timeRest: data.timeRest,
      timeWork: data.timeWork,
    ));
  }
}
