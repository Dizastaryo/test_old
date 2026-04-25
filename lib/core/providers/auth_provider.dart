import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? accessToken;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.accessToken,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? accessToken,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(const AuthState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final token = await _apiClient.getAccessToken();
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isLoading: true);
      try {
        final response = await _apiClient.get(ApiEndpoints.me);
        final user = User.fromJson(response.data as Map<String, dynamic>);
        state = AuthState(
          isAuthenticated: true,
          user: user,
          accessToken: token,
        );
      } catch (_) {
        await _apiClient.clearTokens();
        state = const AuthState();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _apiClient.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      state = AuthState(
        isAuthenticated: true,
        user: user,
        accessToken: accessToken,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: apiErrorMessage(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _apiClient.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      state = AuthState(
        isAuthenticated: true,
        user: user,
        accessToken: accessToken,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: apiErrorMessage(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {}
    await _apiClient.clearTokens();
    state = const AuthState();
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Demo login for development/offline mode
  void demoLogin() {
    state = AuthState(
      isAuthenticated: true,
      user: User.demoMe,
      accessToken: 'demo_token',
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(apiClient);
});
