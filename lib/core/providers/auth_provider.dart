import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../../data/mock_service.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.isAuthenticated = false, this.user, this.isLoading = false, this.error});

  AuthState copyWith({bool? isAuthenticated, User? user, bool? isLoading, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final mock = MockService.instance;
    if (mock.isAuthenticated) {
      state = AuthState(isAuthenticated: true, user: mock.currentUser);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await MockService.instance.login(email, password);
      state = AuthState(isAuthenticated: true, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({required String username, required String email, required String password, required String fullName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await MockService.instance.register(username: username, email: email, password: password, fullName: fullName);
      state = AuthState(isAuthenticated: true, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await MockService.instance.logout();
    state = const AuthState();
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void demoLogin() {
    final mock = MockService.instance;
    state = AuthState(isAuthenticated: true, user: mock.currentUser);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
