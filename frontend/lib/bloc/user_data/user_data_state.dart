abstract class UserDataState {}

class UserDataInitial extends UserDataState {}

class UserDataLoading extends UserDataState {}

class UserDataLoaded extends UserDataState {
  final String? sessionId;
  final String? userId;
  final String? username;
  final String? country;
  final String? city;
  final String? email;
  final String? administrator;
  final String? verified;
  final String? mood;

  UserDataLoaded({
    this.sessionId,
    this.userId,
    this.username,
    this.country,
    this.city,
    this.email,
    this.administrator,
    this.verified,
    this.mood,
  });

  bool get hasSession => sessionId != null && sessionId!.isNotEmpty;
  bool get hasUserId => userId != null && userId!.isNotEmpty;
}

class UserDataError extends UserDataState {
  final String message;

  UserDataError(this.message);
}
