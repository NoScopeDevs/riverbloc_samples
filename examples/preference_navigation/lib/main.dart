import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_navigation/app/app.dart';
import 'package:preference_navigation/app/app_bloc_observer.dart';
import 'package:preference_navigation/preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_repository/shared_preferences_repository.dart';

Future<void> main() async {
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = AppBlocObserver();

  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final preferences = await SharedPreferences.getInstance();
      final preferencesRepository = SharedPreferencesRepository(
        sharedPreferences: preferences,
      );

      runApp(
        ProviderScope(
          overrides: [
            preferencesRepositoryProvider.overrideWithValue(
              preferencesRepository,
            )
          ],
          child: const App(),
        ),
      );
    },
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
