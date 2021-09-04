import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_navigation/preferences/preferences.dart';
import 'package:preference_navigation/start/start.dart';

/// {@template home_page}
/// Handles the home user interface.
/// {@endtemplate}
class HomePage extends StatelessWidget {
  /// {@macro home_page}
  const HomePage({Key? key}) : super(key: key);

  /// Returns a [MaterialPageRoute] to navigate to `this` widget.
  static Route go() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: HomeView());
}

/// {@template home_view}
/// Handles the user interfaces for [PreferencesBloc] states.
/// {@endtemplate}
class HomeView extends ConsumerWidget {
  /// {@macro home_view}
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PreferencesState>(preferencesBlocProvider, (state) async {
      if (state is PreferencesEmpty) {
        await Navigator.of(context).push<void>(StartPage.go());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your saved values'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(preferencesBlocProvider.bloc).add(PreferencesCleared());
            },
            icon: const Icon(Icons.clear),
          )
        ],
      ),
      body: Center(
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(preferencesBlocProvider);
            if (state is PreferencesLoaded) {
              return PreferencesList(preferences: state.preferences);
            }
            return const Text('Something went wrong...');
          },
        ),
      ),
    );
  }
}

/// {@template preferences_list}
/// Handles the interface that shows the stored preferences.
/// {@endtemplate}
class PreferencesList extends StatelessWidget {
  /// {@macro preferences_list}
  const PreferencesList({
    Key? key,
    required this.preferences,
  }) : super(key: key);

  /// Current preferences stored on device.
  final Map preferences;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: preferences.length,
      itemBuilder: (_, index) {
        final key = preferences.keys.elementAt(index) as String;
        final value = preferences.values.elementAt(index) as String;
        return ListTile(
          title: Text(key),
          subtitle: Text(value),
        );
      },
    );
  }
}
