import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../authentication/presentation/controller/auth_controller.dart';

class BankTabWidget extends StatefulWidget {
  final TextEditingController accountNumberController;
  final TextEditingController ifscController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  const BankTabWidget({
    super.key,
    required this.accountNumberController,
    required this.ifscController,
    required this.formKey,
    required this.onSave,
  });

  @override
  State<BankTabWidget> createState() => _BankTabWidgetState();
}

class _BankTabWidgetState extends State<BankTabWidget> {
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
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your bank details are secured with industry-standard encryption',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Number Field
            TextFormField(
              controller: widget.accountNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: 'Enter your bank account number',
                prefixIcon: const Icon(
                  Icons.account_balance,
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
                if (value?.trim().isEmpty == true) {
                  return 'Enter account number';
                }
                if (value!.length < 8) {
                  return 'Account number must be at least 8 digits';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // IFSC Code Field
            TextFormField(
              controller: widget.ifscController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'IFSC Code',
                hintText: 'Enter IFSC code (e.g., SBIN0001234)',
                prefixIcon: const Icon(
                  Icons.code,
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
                if (value?.trim().isEmpty == true) {
                  return 'Enter IFSC code';
                }
                final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                if (!ifscRegex.hasMatch(value!.toUpperCase())) {
                  return 'Enter a valid IFSC code';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

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
                            'Save Bank Details',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}