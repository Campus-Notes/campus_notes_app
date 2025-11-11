import 'package:campus_notes_app/features/authentication/presentation/screens/forgot_password_feature.dart';
import 'package:campus_notes_app/features/authentication/presentation/widgets/phone_otp.dart';
import 'package:campus_notes_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthController>(context, listen: false);
    auth.login(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Email
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
                    hintText: 'Email Address',
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (v) => v?.trim().isEmpty == true ? 'Enter email' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Password
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
                    hintText: 'Password',
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (v) => (v?.isEmpty == true || v!.length < 6) ? 'Min 6 chars' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Forgot Password → navigates
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.blueLink, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenButton,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Login',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 30),

              // Or login with
              Text('Or login with',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Google login not implemented yet'))),
                        icon: const Icon(Icons.g_mobiledata, size: 20),
                        label: const Text('Google', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextButton.icon(
                        onPressed: () => _showPhoneOTPDialog(context),
                        icon: const Icon(Icons.phone_outlined, size: 20),
                        label: const Text('Phone', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhoneOTPDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const PhoneOTPDialog());
  }
}