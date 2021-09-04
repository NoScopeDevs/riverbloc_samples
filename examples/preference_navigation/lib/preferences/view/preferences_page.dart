import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_navigation/home/home.dart';
import 'package:preference_navigation/preferences/preferences.dart';
import 'package:preference_navigation/start/start.dart';

/// {@template preferences_page}
/// Handles the preferences user interfaces.
/// {@endtemplate}
class PreferencesPage extends ConsumerWidget {
  /// {@macro preferences_page}
  const PreferencesPage({Key? key}) : super(key: key);

  /// Returns a [MaterialPageRoute] to navigate to `this` widget.
  static Route go() {
    return MaterialPageRoute<void>(builder: (_) => const PreferencesPage());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PreferencesState>(preferencesBlocProvider, (state) async {
      if (state is PreferencesLoaded) {
        await Navigator.of(context).push<void>(HomePage.go());
      }
      if (state is PreferencesError) {
        // ignore: use_build_context_synchronously
        await Navigator.of(context).pushReplacement<void, void>(
          StartPage.go(),
        );
      }
    });
    return const Scaffold(
      body: Center(child: PreferencesForm()),
    );
  }
}
