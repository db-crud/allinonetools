import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/app_user.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    _initAuth();
  }

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  static const String _kSessionKey = 'db_pdf_tools_user_session';

  Future<void> _initAuth() async {
    // 1. Listen to Supabase Auth state changes
    try {
      final client = _supabase;
      if (client != null) {
        client.auth.onAuthStateChange.listen((data) async {
          final session = data.session;
          final user = session?.user;
          if (user != null) {
            _currentUser = _mapUser(user);
            await _persistSessionToPrefs(_currentUser);
          } else if (data.event == AuthChangeEvent.signedOut) {
            _currentUser = null;
            await _persistSessionToPrefs(null);
          }
          notifyListeners();
        });

        // Check if an active session already exists in client
        final initialUser = client.auth.currentUser;
        if (initialUser != null) {
          _currentUser = _mapUser(initialUser);
          await _persistSessionToPrefs(_currentUser);
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('Supabase Auth listener initialization: $e');
    }

    // 2. Check SharedPreferences for existing cached user session
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_kSessionKey);
      if (sessionJson != null && sessionJson.isNotEmpty) {
        final data = jsonDecode(sessionJson) as Map<String, dynamic>;
        _currentUser = AppUser.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Session restore error: $e');
    }
  }

  AppUser _mapUser(User user) {
    final meta = user.userMetadata ?? {};
    final fullName = meta['name'] as String? ??
        meta['full_name'] as String? ??
        (user.email != null ? user.email!.split('@').first : 'User');
    final avatar = meta['avatar_url'] as String? ?? meta['picture'] as String?;

    return AppUser(
      id: user.id,
      email: user.email ?? 'user@supabase.io',
      name: fullName,
      avatarUrl: avatar,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  Future<void> _persistSessionToPrefs(AppUser? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString(_kSessionKey, jsonEncode(user.toJson()));
      } else {
        await prefs.remove(_kSessionKey);
      }
    } catch (_) {}
  }

  /// Sign In with Email & Password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      _errorMessage = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final client = _supabase;
      if (client != null) {
        final response = await client.auth.signInWithPassword(
          email: cleanEmail,
          password: password,
        );
        if (response.user != null) {
          _currentUser = _mapUser(response.user!);
          await _persistSessionToPrefs(_currentUser);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } on AuthException catch (e) {
      _errorMessage = _parseAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _errorMessage = 'Unable to connect to Supabase authentication server.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign Up with Email, Password & Name.
  /// Returns a record: (success: bool, requiresOtp: bool)
  Future<({bool success, bool requiresOtp})> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim();
    final cleanName = name.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      _errorMessage = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return (success: false, requiresOtp: false);
    }
    if (cleanName.isEmpty) {
      _errorMessage = 'Please enter your full name';
      _isLoading = false;
      notifyListeners();
      return (success: false, requiresOtp: false);
    }
    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      _isLoading = false;
      notifyListeners();
      return (success: false, requiresOtp: false);
    }

    try {
      final client = _supabase;
      if (client != null) {
        final response = await client.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {
            'name': cleanName,
            'full_name': cleanName,
          },
        );

        if (response.user != null) {
          // If session is null, email confirmation / OTP is required to activate account
          final bool requiresOtp = response.session == null;

          if (!requiresOtp) {
            _currentUser = _mapUser(response.user!);
            await _persistSessionToPrefs(_currentUser);
          }

          _isLoading = false;
          notifyListeners();
          return (success: true, requiresOtp: requiresOtp);
        }
      }
    } on AuthException catch (e) {
      _errorMessage = _parseAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return (success: false, requiresOtp: false);
    } catch (e) {
      _errorMessage = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return (success: false, requiresOtp: false);
    }

    _errorMessage = 'Supabase client not initialized';
    _isLoading = false;
    notifyListeners();
    return (success: false, requiresOtp: false);
  }

  /// Verify Email OTP after Sign-Up
  Future<bool> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim();
    final cleanToken = token.trim();

    if (cleanToken.length < 6) {
      _errorMessage = 'Please enter the complete 6-digit OTP code.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final client = _supabase;
      if (client != null) {
        // First try standard OtpType.signup
        try {
          final response = await client.auth.verifyOTP(
            email: cleanEmail,
            token: cleanToken,
            type: OtpType.signup,
          );
          if (response.user != null) {
            _currentUser = _mapUser(response.user!);
            await _persistSessionToPrefs(_currentUser);
            _isLoading = false;
            notifyListeners();
            return true;
          }
        } catch (_) {
          // Fallback to OtpType.email in case provider configuration uses general email confirmation
          final response = await client.auth.verifyOTP(
            email: cleanEmail,
            token: cleanToken,
            type: OtpType.email,
          );
          if (response.user != null) {
            _currentUser = _mapUser(response.user!);
            await _persistSessionToPrefs(_currentUser);
            _isLoading = false;
            notifyListeners();
            return true;
          }
        }
      }
    } on AuthException catch (e) {
      _errorMessage = _parseAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'OTP verification failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _errorMessage = 'Invalid or expired OTP code. Please check and try again.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Resends sign-up verification OTP
  Future<bool> resendSignupOtp(String email) async {
    _errorMessage = null;
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      _errorMessage = 'Please enter a valid email address';
      return false;
    }

    try {
      final client = _supabase;
      if (client != null) {
        await client.auth.resend(
          type: OtpType.signup,
          email: cleanEmail,
        );
        return true;
      }
    } on AuthException catch (e) {
      _errorMessage = _parseAuthErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Failed to resend code: ${e.toString()}';
      return false;
    }
    return false;
  }

  /// Sends Supabase password recovery email
  /// Note: Returns true generically to avoid leaking whether an email exists
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      _errorMessage = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final client = _supabase;
      if (client != null) {
        await client.auth.resetPasswordForEmail(
          cleanEmail,
          redirectTo: kIsWeb ? null : 'io.supabase.dbpdftools://login-callback',
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      debugPrint('Supabase resetPasswordForEmail notice: ${e.message}');
      _isLoading = false;
      notifyListeners();
      // Keep confirmation generic for user privacy & anti-enumeration
      return true;
    } catch (e) {
      debugPrint('Password reset exception: $e');
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// Verifies recovery OTP and updates password directly
  Future<bool> verifyRecoveryOtpAndResetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim();
    final cleanToken = token.trim();

    if (cleanToken.length < 6) {
      _errorMessage = 'Please enter the 6-digit recovery code.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    if (newPassword.length < 6) {
      _errorMessage = 'New password must be at least 6 characters.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final client = _supabase;
      if (client != null) {
        final verifyRes = await client.auth.verifyOTP(
          email: cleanEmail,
          token: cleanToken,
          type: OtpType.recovery,
        );

        if (verifyRes.user != null || client.auth.currentUser != null) {
          await client.auth.updateUser(
            UserAttributes(password: newPassword),
          );

          final activeUser = client.auth.currentUser;
          if (activeUser != null) {
            _currentUser = _mapUser(activeUser);
            await _persistSessionToPrefs(_currentUser);
          }
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } on AuthException catch (e) {
      _errorMessage = _parseAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to reset password: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _errorMessage = 'Invalid or expired recovery code.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Real Google OAuth with Supabase
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final client = _supabase;
      if (client != null) {
        final success = await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.dbpdftools://login-callback',
          authScreenLaunchMode: kIsWeb
              ? LaunchMode.platformDefault
              : LaunchMode.externalApplication,
        );

        _isLoading = false;
        notifyListeners();
        return success;
      }
    } on AuthException catch (e) {
      _errorMessage = _parseAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') || msg.contains('canceled') || msg.contains('cancelled')) {
        _errorMessage = 'Google sign-in was cancelled.';
      } else {
        _errorMessage =
            'Google Sign-In requires provider activation in Supabase dashboard. ($e)';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _errorMessage = 'Supabase client not initialized';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign Out from Supabase
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      final client = _supabase;
      if (client != null) {
        await client.auth.signOut();
      }
    } catch (e) {
      debugPrint('Supabase signOut error: $e');
    }

    _currentUser = null;
    await _persistSessionToPrefs(null);
    _isLoading = false;
    notifyListeners();
  }

  String _parseAuthErrorMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
      return 'Invalid email or password. Please verify your details.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email address with the OTP before logging in.';
    }
    if (msg.contains('user already registered') || msg.contains('already exists')) {
      return 'An account with this email already exists. Please log in.';
    }
    if (msg.contains('token has expired') || msg.contains('otp has expired')) {
      return 'The OTP verification code has expired. Please request a new code.';
    }
    if (msg.contains('token is invalid') || msg.contains('invalid token')) {
      return 'The verification code entered is incorrect. Please recheck.';
    }
    if (msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a few moments before trying again.';
    }
    return e.message;
  }
}
