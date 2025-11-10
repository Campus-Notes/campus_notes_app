import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../authentication/presentation/controller/auth_controller.dart';

class UpiTabWidget extends StatefulWidget {
  final TextEditingController upiIdController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  const UpiTabWidget({
    super.key,
    required this.upiIdController,
    required this.formKey,
    required this.onSave,
  });

  @override
  State<UpiTabWidget> createState() => _UpiTabWidgetState();
}

class _UpiTabWidgetState extends State<UpiTabWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add your UPI ID to receive payments quickly and securely',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // UPI ID Field
            TextFormField(
              controller: widget.upiIdController,
              decoration: InputDecoration(
                labelText: 'UPI ID',
                hintText: 'example@paytm, user@phonepay, etc.',
                prefixIcon: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.07),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty == true) return null; // UPI is optional
                
                // Basic UPI ID validation
                final upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+$');
                if (!upiRegex.hasMatch(value!)) {
                  return 'Enter a valid UPI ID (e.g., user@paytm)';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            Consumer<AuthController>(
              builder: (context, auth, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : widget.onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save UPI Details',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}