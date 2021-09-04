import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:preferences_repository/preferences_repository.dart';
import 'package:riverbloc/riverbloc.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

/// [Provider] that gives access to [PreferencesRepository]
final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => throw UnimplementedError(
    'Override with a real implementation, on the ProviderScope(overrides)',
  ),
);

/// [BlocProvider] that gives access to [PreferencesBloc]
final preferencesBlocProvider = BlocProvider<PreferencesBloc, PreferencesState>(
  (ref) => PreferencesBloc(repository: ref.read(preferencesRepositoryProvider))
    ..add(PreferencesChecked()),
);

/// {@template preferences_bloc}
/// [Bloc] that handles preferences business logic.
/// {@endtemplate}
class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  /// {@macro preferences_bloc}
  PreferencesBloc({
    required PreferencesRepository repository,
  })  : _repository = repository,
        super(const PreferencesInitial()) {
    on<PreferenceAdded>(_onPreferenceAdded);
    on<PreferencesChecked>(_onPreferencesChecked);
    on<PreferencesCleared>(_onPreferencesCleared);
  }

  final PreferencesRepository _repository;

  Future<void> _onPreferenceAdded(PreferenceAdded event, Emitter emit) async {
    try {
      final key = event.entry.keys.first;
      final value = event.entry.values.first as Object;

      emit(const PreferencesLoading());
      await _repository.saveValue(key, value);

      add(PreferencesChecked());
    } catch (e) {
      emit(_handleError(e));
    }
  }

  Future<void> _onPreferencesChecked(
    PreferencesChecked event,
    Emitter emit,
  ) async {
    try {
      final keys = _repository.getKeys();
      if (keys.isEmpty) emit(const PreferencesEmpty());

      final preferences = <String, dynamic>{};
      for (final key in keys) {
        preferences.addAll(<String, dynamic>{key: _repository.getValue(key)});
      }

      emit(PreferencesLoaded(preferences));
    } catch (e) {
      emit(_handleError(e));
    }
  }

  Future<void> _onPreferencesCleared(
    PreferencesCleared event,
    Emitter emit,
  ) async {
    try {
      await _repository.clearValues();
      emit(const PreferencesEmpty());
    } catch (e) {
      emit(_handleError(e));
    }
  }

  PreferencesState _handleError(Object e) {
    if (e is PreferencesError) return PreferencesError(e.error, e.stackTrace);
    return const PreferencesError();
  }
}
