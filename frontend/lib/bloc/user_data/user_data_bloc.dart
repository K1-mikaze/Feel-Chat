import 'package:bloc/bloc.dart';
import 'package:frontend/bloc/user_data/user_data_event.dart';
import 'package:frontend/bloc/user_data/user_data_state.dart';
import 'package:frontend/data/repositories/user_data_repository.dart';

class UserDataBloc extends Bloc<UserDataEvent, UserDataState> {
  static final UserDataBloc instance = UserDataBloc();
  final UserDataRepository _repository = UserDataRepository();

  UserDataBloc() : super(UserDataInitial()) {
    on<LoadUserData>(_onLoadUserData);
  }

  Future<void> _onLoadUserData(
    LoadUserData event,
    Emitter<UserDataState> emit,
  ) async {
    emit(UserDataLoading());
    try {
      final data = await _repository.loadUserData();
      emit(
        UserDataLoaded(
          sessionId: data['session-id'],
          userId: data['id'],
          username: data['username'],
          country: data['country'],
          city: data['city'],
          email: data['email'],
          administrator: data['administrator'],
          verified: data['verified'],
          mood: data['mood'],
        ),
      );
    } catch (e) {
      emit(UserDataError(e.toString()));
    }
  }
}
