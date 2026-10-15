import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionState {
  final String? userId;
  final String? userName;
  final bool isLoggedIn;

  const SessionState({this.userId, this.userName, this.isLoggedIn = false});

  SessionState copyWith({String? userId, String? userName, bool? isLoggedIn}) {
    return SessionState(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState());

  void login(String userId, String userName) {
    state = SessionState(userId: userId, userName: userName, isLoggedIn: true);
  }

  void logout() {
    state = const SessionState();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) => SessionNotifier(),
);
