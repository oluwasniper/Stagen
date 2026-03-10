import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_router.dart';
import '../utils/error_localizer.dart';
import '../utils/app_motion.dart';
import '../utils/route/app_path.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAnonymous() async {
    await ref.read(authProvider.notifier).signInAnonymously();
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      AppGoRouter.router.go(AppPath.home);
    } else if (auth.error != null) {
      _showError(auth.error!, auth.errorType);
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (_isSignUp) {
      await ref.read(authProvider.notifier).signUp(
            email: email,
            password: password,
            name: name.isNotEmpty ? name : null,
          );
    } else {
      await ref.read(authProvider.notifier).signIn(
            email: email,
            password: password,
          );
    }

    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      AppGoRouter.router.go(AppPath.home);
    } else if (auth.error != null) {
      _showError(auth.error!, auth.errorType);
    }
  }

  void _showError(String message, [String? errorType]) {
    final l10n = AppLocalizations.of(context);

    // Strip Appwrite exception wrapper for a fallback message
    String fallback = message;
    if (fallback.contains('AppwriteException:')) {
      fallback = fallback.split('AppwriteException:').last.trim();
      fallback = fallback.replaceAll(RegExp(r'\s*\(\d+\)\s*$'), '');
      // Remove the error type prefix (e.g. "user_already_exists, ")
      fallback = fallback.replaceAll(RegExp(r'^[a-z_]+,\s*'), '');
    }
    if (fallback.contains('Failed host lookup')) {
      fallback =
          'Network error: unable to reach Appwrite host. Check internet/DNS and APPWRITE_ENDPOINT.';
    }

    final localized = localizeApiError(l10n, errorType, fallback);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localized),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);
    final isLoading = auth.status == AuthStatus.loading;
    final motion = AppMotion.of(context);

    return Scaffold(
      backgroundColor: const Color(0xff333333),
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Language Switcher (top-right) ───
            Positioned(
              top: 8,
              right: 8,
              child: _LanguageChip(ref: ref),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ─── Logo / Title ───
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 80,
                      color: const Color(0xffFDB623),
                    )
                        .animate()
                        .fadeIn(duration: motion.duration(AppMotion.slow))
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: motion.duration(AppMotion.slow),
                          curve: motion.curve(AppMotion.spring),
                        ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appName,
                      style: const TextStyle(
                        color: Color(0xffFDB623),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(
                        delay: motion.delay(AppMotion.fast),
                        duration: motion.duration(AppMotion.medium)),
                    const SizedBox(height: 40),

                    // ─── Email / Password Form ───
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name field (only in sign-up mode)
                          if (_isSignUp) ...[
                            _buildTextField(
                              controller: _nameController,
                              hint: l10n.authName,
                              icon: Icons.person_outline_rounded,
                              validator: null, // name is optional
                            ),
                            const SizedBox(height: 14),
                          ],

                          _buildTextField(
                            controller: _emailController,
                            hint: l10n.authEmail,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.authEmailRequired;
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                  .hasMatch(v.trim())) {
                                return l10n.authEmailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          _buildTextField(
                            controller: _passwordController,
                            hint: l10n.authPassword,
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: const Color(0xffFDB623)
                                    .withValues(alpha: 0.7),
                              ),
                              onPressed: () {
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return l10n.authPasswordRequired;
                              }
                              if (v.length < 8) {
                                return l10n.authPasswordTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Sign In / Sign Up button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffFDB623),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : _handleEmailAuth,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      _isSignUp
                                          ? l10n.authSignUp
                                          : l10n.authSignIn,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: motion.delay(AppMotion.fast),
                          duration: motion.duration(AppMotion.slow),
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: motion.delay(AppMotion.fast),
                          duration: motion.duration(AppMotion.slow),
                          curve: motion.curve(AppMotion.enter),
                        ),

                    const SizedBox(height: 14),

                    // Toggle sign-in / sign-up
                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp
                            ? l10n.authSwitchToSignIn
                            : l10n.authSwitchToSignUp,
                        style: const TextStyle(
                          color: Color(0xffD9D9D9),
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Divider ───
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(
                                color: Color(0xff555555), thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.authOr,
                            style: const TextStyle(
                              color: Color(0xffD9D9D9),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(
                            child: Divider(
                                color: Color(0xff555555), thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ─── Continue Without Account ───
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffFDB623)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _handleAnonymous,
                        icon: const Icon(Icons.person_off_outlined,
                            color: Color(0xffFDB623)),
                        label: Text(
                          l10n.authContinueAnonymous,
                          style: const TextStyle(
                            color: Color(0xffFDB623),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: motion.delay(AppMotion.slow),
                          duration: motion.duration(AppMotion.medium),
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: motion.delay(AppMotion.slow),
                          duration: motion.duration(AppMotion.medium),
                          curve: motion.curve(AppMotion.enter),
                        ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        prefixIcon:
            Icon(icon, color: const Color(0xffFDB623).withValues(alpha: 0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xff444444),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffFDB623), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

/// Compact language chip button shown on the auth screen.
///
/// Displays the current language code and opens a bottom-sheet picker on tap.
class _LanguageChip extends StatelessWidget {
  final WidgetRef ref;
  const _LanguageChip({required this.ref});

  void _showPicker(BuildContext context) {
    final currentLocale = ref.read(localeProvider);
    final motion = AppMotion.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff333333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xffFDB623),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ...L10n.all.asMap().entries.map((entry) {
                final index = entry.key;
                final locale = entry.value;
                final isSelected =
                    locale.languageCode == currentLocale.languageCode;
                final name = L10n.languageNames[locale.languageCode] ??
                    locale.languageCode;

                return ListTile(
                  leading: AnimatedContainer(
                    duration: motion.duration(AppMotion.fast),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xffFDB623)
                          : Colors.transparent,
                      border: Border.all(
                        color: const Color(0xffFDB623),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 16, color: Color(0xff333333))
                        : null,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xffFDB623)
                          : const Color(0xffD9D9D9),
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(locale);
                    Navigator.pop(ctx);
                  },
                )
                    .animate()
                    .fadeIn(
                      delay: motion.delay(Duration(milliseconds: 60 * index)),
                      duration:
                          motion.duration(const Duration(milliseconds: 250)),
                    )
                    .slideX(
                      begin: 0.1,
                      end: 0,
                      delay: motion.delay(Duration(milliseconds: 60 * index)),
                      duration:
                          motion.duration(const Duration(milliseconds: 250)),
                      curve: motion.curve(AppMotion.enter),
                    );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    final code = ref.watch(localeProvider).languageCode.toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color(0xffFDB623).withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded,
                  size: 18, color: Color(0xffFDB623)),
              const SizedBox(width: 4),
              Text(
                code,
                style: const TextStyle(
                  color: Color(0xffFDB623),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
          delay: motion.delay(const Duration(milliseconds: 600)),
          duration: motion.duration(AppMotion.medium),
        );
  }
}
