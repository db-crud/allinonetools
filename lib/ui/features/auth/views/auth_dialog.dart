import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/auth_service.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/widgets/brand_logo.dart';

enum AuthMode {
  login,
  signUp,
  verifyOtp,
  forgotPassword,
  resetWithOtp,
}

class AuthDialog extends StatefulWidget {
  final HomeViewModel viewModel;
  final bool initialIsSignUp;

  const AuthDialog({
    super.key,
    required this.viewModel,
    this.initialIsSignUp = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required HomeViewModel viewModel,
    bool isSignUp = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AuthDialog(
        viewModel: viewModel,
        initialIsSignUp: isSignUp,
      ),
    );
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late AuthMode _currentMode;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final _recoveryOtpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureNewPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Countdown timer for OTP resend (60 seconds)
  Timer? _countdownTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialIsSignUp ? AuthMode.signUp : AuthMode.login;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _recoveryOtpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _startResendCountdown([int seconds = 60]) {
    _countdownTimer?.cancel();
    setState(() {
      _resendCountdown = seconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _resendCountdown = 0;
        });
        timer.cancel();
      }
    });
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _currentMode = mode;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  // 1. Email & Password Login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = AuthService();
    final success = await auth.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.viewModel.onUserAuthenticated();
      Navigator.pop(context, true);
      _showToast('Welcome back! You are logged in.');
    } else {
      setState(() {
        _errorMessage = auth.errorMessage ?? 'Login failed. Please check your credentials.';
      });
    }
  }

  // 2. Sign Up with Email OTP flow
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = AuthService();
    final result = await auth.signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      if (result.requiresOtp) {
        // Transition to OTP verification screen
        _otpController.clear();
        _startResendCountdown(60);
        setState(() {
          _currentMode = AuthMode.verifyOtp;
          _successMessage =
              'Verification code sent to ${_emailController.text.trim()}. Please enter the 6-digit OTP below.';
        });
      } else {
        // Direct session activation
        widget.viewModel.onUserAuthenticated();
        Navigator.pop(context, true);
        _showToast('Account created successfully! Welcome to DB PDF Tools.');
      }
    } else {
      setState(() {
        _errorMessage = auth.errorMessage ?? 'Registration failed. Please try again.';
      });
    }
  }

  // 3. Verify OTP
  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit OTP code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = AuthService();
    final success = await auth.verifySignupOtp(
      email: _emailController.text,
      token: otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.viewModel.onUserAuthenticated();
      Navigator.pop(context, true);
      _showToast('Email verified successfully! Welcome to DB PDF Tools.');
    } else {
      setState(() {
        _errorMessage = auth.errorMessage ?? 'Invalid verification code. Please try again.';
      });
    }
  }

  // 4. Resend OTP
  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = AuthService();
    final success = await auth.resendSignupOtp(_emailController.text);

    if (!mounted) return;
    if (success) {
      _startResendCountdown(60);
      setState(() {
        _successMessage = 'A fresh 6-digit verification code has been sent to your email.';
      });
    } else {
      setState(() {
        _errorMessage = auth.errorMessage ?? 'Failed to resend OTP. Please wait before retrying.';
      });
    }
  }

  // 5. Send Password Reset Email
  Future<void> _handleSendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid registered email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = AuthService();
    await auth.sendPasswordResetEmail(email);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _successMessage =
          'If an account exists with this email, password recovery instructions and a 6-digit code have been sent. Please check your inbox and spam folder.';
    });
  }

  // 6. Reset Password with Recovery OTP
  Future<void> _handleResetWithRecoveryOtp() async {
    final email = _emailController.text.trim();
    final code = _recoveryOtpController.text.trim();
    final newPass = _newPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter your account email.');
      return;
    }
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit recovery code.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _errorMessage = 'New password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = AuthService();
    final success = await auth.verifyRecoveryOtpAndResetPassword(
      email: email,
      token: code,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.viewModel.onUserAuthenticated();
      Navigator.pop(context, true);
      _showToast('Password reset successfully! You are now signed in.');
    } else {
      setState(() {
        _errorMessage = auth.errorMessage ?? 'Failed to reset password. Please check the code.';
      });
    }
  }

  // 7. Google OAuth Sign In
  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = AuthService();
    final success = await auth.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.viewModel.onUserAuthenticated();
      Navigator.pop(context, true);
      _showToast('Signed in with Google successfully!');
    } else {
      setState(() {
        _errorMessage = auth.errorMessage ?? 'Google authentication was cancelled or could not be completed.';
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _autofillDemo() {
    _emailController.text = 'dan@dbpdftools.com';
    _passwordController.text = 'password123';
    _confirmPasswordController.text = 'password123';
    _nameController.text = 'Dan Bahadur';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.15),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) _buildNotificationCard(_errorMessage!, isError: true),
                  if (_successMessage != null) _buildNotificationCard(_successMessage!, isError: false),
                  _buildBodyForCurrentMode(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const BrandLogo(size: 34),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DB PDF Tools',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  _getHeaderSubtitle(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
          splashRadius: 18,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  String _getHeaderSubtitle() {
    switch (_currentMode) {
      case AuthMode.login:
        return 'Sign in to access tools & cloud sync';
      case AuthMode.signUp:
        return 'Create account with Email OTP';
      case AuthMode.verifyOtp:
        return 'Verify 6-digit confirmation code';
      case AuthMode.forgotPassword:
        return 'Reset your account password';
      case AuthMode.resetWithOtp:
        return 'Enter recovery code & new password';
    }
  }

  Widget _buildNotificationCard(String message, {required bool isError}) {
    final color = isError ? AppColors.error : AppColors.primary;
    final icon = isError ? Icons.error_outline_rounded : Icons.info_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyForCurrentMode() {
    switch (_currentMode) {
      case AuthMode.login:
        return _buildLoginView();
      case AuthMode.signUp:
        return _buildSignUpView();
      case AuthMode.verifyOtp:
        return _buildVerifyOtpView();
      case AuthMode.forgotPassword:
        return _buildForgotPasswordView();
      case AuthMode.resetWithOtp:
        return _buildResetWithOtpView();
    }
  }

  // --- 1. Login View ---
  Widget _buildLoginView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModeSwitcher(isLogin: true),
        const SizedBox(height: 18),

        // Email field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Email address', Icons.mail_outline_rounded),
          validator: (val) {
            if (val == null || !val.contains('@') || val.trim().length < 5) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Password field with show/hide
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _inputDecoration('Password', Icons.lock_outline_rounded).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (val) {
            if (val == null || val.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),

        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => _switchMode(AuthMode.forgotPassword),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        // Login Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('Login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),

        const SizedBox(height: 16),
        _buildOrDivider(),
        const SizedBox(height: 16),

        // Continue with Google
        _buildGoogleButton(),

        const SizedBox(height: 14),

        // Link to Sign Up
        Center(
          child: TextButton(
            onPressed: () => _switchMode(AuthMode.signUp),
            child: const Text(
              "Don't have an account? Sign Up",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        _buildAutofillHelper(),
      ],
    );
  }

  // --- 2. Sign Up View ---
  Widget _buildSignUpView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModeSwitcher(isLogin: false),
        const SizedBox(height: 18),

        // Full Name
        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration('Full Name', Icons.person_outline_rounded),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Email address', Icons.mail_outline_rounded),
          validator: (val) {
            if (val == null || !val.contains('@') || val.trim().length < 5) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _inputDecoration('Password (min. 6 characters)', Icons.lock_outline_rounded).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (val) {
            if (val == null || val.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Confirm Password
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: _inputDecoration('Confirm Password', Icons.lock_clock_outlined).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          validator: (val) {
            if (val != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Sign Up Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _handleSignUp,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Sign Up & Send OTP',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        ),

        const SizedBox(height: 16),
        _buildOrDivider(),
        const SizedBox(height: 16),

        // Continue with Google
        _buildGoogleButton(),

        const SizedBox(height: 14),

        // Link to Login
        Center(
          child: TextButton(
            onPressed: () => _switchMode(AuthMode.login),
            child: const Text(
              'Already have an account? Login',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        _buildAutofillHelper(),
      ],
    );
  }

  // --- 3. OTP Verification View ---
  Widget _buildVerifyOtpView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.mark_email_read_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Enter Verification Code',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Supabase has sent a 6-digit confirmation code to ${_emailController.text.trim()}.',
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 6-digit OTP Input
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            letterSpacing: 8,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '• • • • • •',
            hintStyle: const TextStyle(letterSpacing: 6, color: AppColors.secondaryText),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Verify Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _handleVerifyOtp,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Verify & Activate Account',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        ),
        const SizedBox(height: 14),

        // Resend OTP Row with Countdown
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive the email?",
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            TextButton(
              onPressed: _resendCountdown > 0 ? null : _handleResendOtp,
              child: Text(
                _resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend Code',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _resendCountdown > 0 ? AppColors.onSurfaceVariant : AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        // Back to Sign Up / Change Email
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Change Email / Back', style: TextStyle(fontSize: 12)),
            onPressed: () => _switchMode(AuthMode.signUp),
          ),
        ),
      ],
    );
  }

  // --- 4. Forgot Password View ---
  Widget _buildForgotPasswordView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Password Recovery',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter your registered email address. We will send password-reset instructions and a 6-digit recovery code.',
          style: TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.35),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Your registered email', Icons.mail_outline_rounded),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _handleSendPasswordReset,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('Send Reset Instructions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 14),

        // Option to enter recovery OTP directly
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.outlineVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.pin_rounded, size: 18, color: AppColors.primary),
          label: const Text(
            'Already have a 6-digit recovery code? Enter here',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          onPressed: () => _switchMode(AuthMode.resetWithOtp),
        ),

        const SizedBox(height: 10),

        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back to Login', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            onPressed: () => _switchMode(AuthMode.login),
          ),
        ),
      ],
    );
  }

  // --- 5. Reset Password With OTP View ---
  Widget _buildResetWithOtpView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Set New Password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter the 6-digit recovery code from your email along with your desired new password.',
          style: TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.35),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Email address', Icons.mail_outline_rounded),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _recoveryOtpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: _inputDecoration('6-digit Recovery Code', Icons.pin_outlined).copyWith(
            counterText: '',
          ),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          decoration: _inputDecoration('New Password (min. 6 chars)', Icons.lock_outline_rounded).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _handleResetWithRecoveryOtp,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('Update Password & Sign In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 10),

        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back to Login', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            onPressed: () => _switchMode(AuthMode.login),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildModeSwitcher({required bool isLogin}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isLogin) _switchMode(AuthMode.login);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isLogin ? AppColors.surfaceCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isLogin
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.08),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isLogin ? FontWeight.w700 : FontWeight.w500,
                    color: isLogin ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isLogin) _switchMode(AuthMode.signUp);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isLogin ? AppColors.surfaceCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !isLogin
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.08),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: !isLogin ? FontWeight.w700 : FontWeight.w500,
                    color: !isLogin ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OR',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
        onPressed: _isLoading ? null : _handleGoogleAuth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
              height: 20,
              width: 20,
              errorBuilder: (ctx, err, stack) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutofillHelper() {
    return Center(
      child: TextButton.icon(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          foregroundColor: AppColors.secondaryText,
        ),
        icon: const Icon(Icons.flash_on_rounded, size: 14),
        label: const Text(
          'Autofill Demo Credentials',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        onPressed: _autofillDemo,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData prefixIcon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.onSurfaceVariant),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
