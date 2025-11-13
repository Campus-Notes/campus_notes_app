import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../common_widgets/app_bar.dart';
import '../../../authentication/presentation/controller/auth_controller.dart';
import '../../../authentication/data/models/user_model.dart';
import '../widgets/payment_status_section.dart';
import '../widgets/upi_tab_widget.dart';
import '../widgets/bank_tab_widget.dart';

class BankDetailsPage extends StatefulWidget {
  const BankDetailsPage({super.key});

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _upiFormKey = GlobalKey<FormState>();
  final _bankFormKey = GlobalKey<FormState>();

  final _upiIdController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _upiIdController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final user = await auth.getCurrentUser();

    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
        _upiIdController.text = user.upiId ?? '';
        _accountNumberController.text = user.bankAccountNumber ?? '';
        _ifscController.text = user.ifscCode ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUpiDetails() async {
    if (!_upiFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthController>(context, listen: false);
    final result = await auth.updateBankDetails(
      upiId: _upiIdController.text.trim(),
    );

    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UPI details updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveBankDetails() async {
    if (!_bankFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthController>(context, listen: false);
    final result = await auth.updateBankDetails(
      bankAccountNumber: _accountNumberController.text.trim(),
      ifscCode: _ifscController.text.trim().toUpperCase(),
    );

    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank details updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppBar(
          text: "Payment Details",
          usePremiumBackIcon: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppBar(
          text: "Payment Details",
          usePremiumBackIcon: true,
        ),
        body: const Center(
          child: Text('Failed to load user data'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        text: "Payment Details",
        usePremiumBackIcon: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            PaymentStatusSection(user: _currentUser!),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                labelColor: Colors.white,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.account_balance_wallet),
                    text: 'UPI Details',
                  ),
                  Tab(
                    icon: Icon(Icons.account_balance),
                    text: 'Bank Details',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  UpiTabWidget(
                    upiIdController: _upiIdController,
                    formKey: _upiFormKey,
                    onSave: _saveUpiDetails,
                  ),
                  BankTabWidget(
                    accountNumberController: _accountNumberController,
                    ifscController: _ifscController,
                    formKey: _bankFormKey,
                    onSave: _saveBankDetails,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
