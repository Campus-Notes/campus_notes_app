import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../theme/app_theme.dart';
import '../../../../common_widgets/app_bar.dart';
import '../../../authentication/presentation/controller/auth_controller.dart';
import '../../../payment/data/services/wallet_service.dart';
import '../../../payment/data/models/user_credit_models.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_withdrawal_info.dart';
import '../widgets/wallet_transaction_list.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletService _walletService = WalletService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  double _balance = 0.0;
  double _points = 0.0;
  bool _isLoading = true;
  bool _isWithdrawing = false;
  List<WalletCreditModel> _walletHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
    _loadWalletHistory();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final balance = await _walletService.getWalletBalance(currentUser.uid);
        final points = await _walletService.getPointsBalance(currentUser.uid);
        
        if (mounted) {
          setState(() {
            _balance = balance;
            _points = points;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error loading wallet data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadWalletHistory() async {
    setState(() => _isLoadingHistory = true);
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final history = await _walletService.getWalletHistory(
          userId: currentUser.uid,
          limit: 50,
        );
        
        if (mounted) {
          setState(() {
            _walletHistory = history;
            _isLoadingHistory = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingHistory = false);
        }
      }
    } catch (e) {
      debugPrint('Error loading wallet history: $e');
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Future<void> _handleWithdrawal() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showErrorDialog('Please log in to withdraw funds');
      return;
    }

    // Check minimum withdrawal amount
    if (_balance < 100) {
      _showErrorDialog(
        'Minimum withdrawal amount is ₹100\n\nYour current balance: ₹${_balance.toStringAsFixed(0)}',
      );
      return;
    }

    // Get user details
    final authController = context.read<AuthController>();
    final userModel = await authController.getCurrentUser();
    
    if (userModel == null) {
      _showErrorDialog('Unable to load user details. Please try again.');
      return;
    }

    // Check if payment details are provided
    if (!userModel.isUPIProvided && !userModel.isBankDetailsProvided) {
      _showErrorDialog(
        'Please add your payment details (UPI or Bank Account) in Payment Details section before withdrawing.',
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showWithdrawalConfirmation(userModel);
    if (!confirmed) return;

    setState(() => _isWithdrawing = true);

    try {
      // Save withdrawal amount before processing
      final withdrawalAmount = _balance;
      
      // Send withdrawal request email FIRST (before DB update)
      final emailSuccess = await _sendWithdrawalRequest(userModel, withdrawalAmount);
      
      // If email failed, show manual option and stop
      if (!emailSuccess) {
        setState(() => _isWithdrawing = false);
        _showManualWithdrawalOption(userModel, withdrawalAmount);
        return;
      }

      // Process withdrawal in database AFTER email is sent
      final withdrawalMethod = userModel.isUPIProvided ? 'UPI' : 'Bank Transfer';
      final withdrawalDetails = userModel.isUPIProvided 
          ? userModel.upiId 
          : '${userModel.bankAccountNumber} (${userModel.ifscCode})';
      
      final dbSuccess = await _walletService.processWithdrawal(
        userId: currentUser.uid,
        amount: withdrawalAmount,
        withdrawalMethod: withdrawalMethod,
        withdrawalDetails: withdrawalDetails,
      );

      if (!dbSuccess) {
        setState(() => _isWithdrawing = false);
        _showErrorDialog('Failed to process withdrawal. Please try again.');
        return;
      }

      // Update local balance immediately
      setState(() {
        _balance = 0.0;
      });

      // Reload wallet history
      await _loadWalletHistory();
      
      setState(() => _isWithdrawing = false);

      // Show success dialog after everything is complete
      _showSuccessDialog();
    } catch (e) {
      setState(() => _isWithdrawing = false);
      _showErrorDialog('An error occurred: ${e.toString()}');
    }
  }

  Future<bool> _showWithdrawalConfirmation(dynamic userModel) async {
    final paymentInfo = userModel.isUPIProvided
        ? 'UPI: ${userModel.upiId}'
        : 'Bank Account: ${userModel.bankAccountNumber}\nIFSC: ${userModel.ifscCode}';

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdrawal Amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${_balance.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(paymentInfo),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Request will be processed within 5-6 hours',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _sendWithdrawalRequest(dynamic userModel, double withdrawalAmount) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final paymentDetails = userModel.isUPIProvided
        ? 'UPI ID: ${userModel.upiId}'
        : 'Bank Account: ${userModel.bankAccountNumber}\nIFSC Code: ${userModel.ifscCode}';

    final emailSubject = Uri.encodeComponent('Withdrawal Request - ${userModel.fullName}');
    final emailBody = Uri.encodeComponent('''
Dear CampusNotes+ Team,

I would like to request a withdrawal from my wallet.

User Details:
- Name: ${userModel.fullName}
- Email: ${userModel.email}
- Mobile: ${userModel.mobile}
- User ID: ${currentUser.uid}

Withdrawal Details:
- Amount: ₹${withdrawalAmount.toStringAsFixed(2)}
- Current Points: ${_points.toStringAsFixed(0)} pts

Payment Details:
$paymentDetails

Please process this withdrawal at your earliest convenience.

Thank you,
${userModel.fullName}
''');

    final emailUri = Uri.parse('mailto:teamcampusnotes@gmail.com?subject=$emailSubject&body=$emailBody');
    
    try {
      final canLaunch = await canLaunchUrl(emailUri);
      debugPrint('Can launch email: $canLaunch');
      
      if (canLaunch) {
        final launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('Email launched: $launched');
        return launched;
      } else {
        // Fallback: try to launch without checking
        try {
          final launched = await launchUrl(
            emailUri,
            mode: LaunchMode.externalApplication,
          );
          return launched;
        } catch (e) {
          debugPrint('Fallback email launch failed: $e');
          return false;
        }
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      // Try alternative approach - just the email address
      try {
        final simpleUri = Uri.parse('mailto:teamcampusnotes@gmail.com');
        final launched = await launchUrl(
          simpleUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          // Show user to manually add details
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email app opened. Please include your withdrawal details manually.'),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
        return launched;
      } catch (e2) {
        debugPrint('Alternative email launch failed: $e2');
        return false;
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('Request Sent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your withdrawal request has been sent successfully!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Processing Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Your request will be processed within 5-6 hours.'),
                  SizedBox(height: 8),
                  Text(
                    'You will receive the amount in your registered payment method.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showManualWithdrawalOption(dynamic userModel, double withdrawalAmount) {
    final paymentDetails = userModel.isUPIProvided
        ? 'UPI ID: ${userModel.upiId}'
        : 'Bank Account: ${userModel.bankAccountNumber}\nIFSC Code: ${userModel.ifscCode}';

    final withdrawalText = '''
Withdrawal Request

User Details:
Name: ${userModel.fullName}
Email: ${userModel.email}
Mobile: ${userModel.mobile}
User ID: ${_auth.currentUser?.uid}

Withdrawal Details:
Amount: ₹${withdrawalAmount.toStringAsFixed(2)}
Points: ${_points.toStringAsFixed(0)} pts

Payment Details:
$paymentDetails
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Client Not Available'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please send the following details manually to:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const SelectableText(
                'teamcampusnotes@gmail.com',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: SelectableText(
                  withdrawalText,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Processing time: 5-6 hours',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Try to open email app with just the address
              final simpleUri = Uri.parse('mailto:teamcampusnotes@gmail.com');
              launchUrl(simpleUri, mode: LaunchMode.externalApplication);
            },
            child: const Text('Open Email'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'Wallet',
        usePremiumBackIcon: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  _loadWalletData(),
                  _loadWalletHistory(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    WalletBalanceCard(balance: _balance),
                    
                    const SizedBox(height: 16),
                    
                    // Withdrawal Info
                    const WalletWithdrawalInfo(),
                    
                    const SizedBox(height: 24),
                    
                    // Withdraw Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isWithdrawing ? null : _handleWithdrawal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ), 
                        ),
                        child: _isWithdrawing
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.account_balance_wallet_outlined),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Withdraw ₹${_balance.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Transaction History
                    WalletTransactionList(
                      transactions: _walletHistory,
                      isLoading: _isLoadingHistory,
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
