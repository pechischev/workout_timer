import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'settings_data.dart';

class SettingsBloc extends Bloc<dynamic, SettingsData> {
  SettingsBloc(): super(const SettingsData());
}
