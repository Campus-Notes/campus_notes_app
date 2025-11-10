import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../common_widgets/form_field.dart';
import '../../../../common_widgets/file_upload.dart';
import '../../../../common_widgets/button/main_button.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '49');
  final _descriptionCtrl = TextEditingController();
  String? _pickedFileName;
  bool _isUploading = false;
  bool _isDonationMode = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _pickFile() async {
    setState(() => _pickedFileName = 'notes.pdf');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('File selected successfully! 📄'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _pickedFileName != null) {
      setState(() => _isUploading = true);
      
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isUploading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(_isDonationMode 
                  ? 'Note donated successfully! ❤️' 
                  : 'Note uploaded successfully! 🎉'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } else if (_pickedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please attach your file'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upload Note',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Earnings Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isDonationMode ? 'Help Other Students' : 'Earn Money & Points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isDonationMode 
                              ? '❤️ Share knowledge freely + earn 15 bonus points'
                              : '💰 Earn 70% of sales + 10 bonus points',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Donation Mode Toggle
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isDonationMode ? Colors.green[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isDonationMode ? Colors.green[300]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isDonationMode ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.volunteer_activism_outlined,
                        color: _isDonationMode ? Colors.green[600] : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Donate Note for Free',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isDonationMode ? Colors.green[700] : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isDonationMode 
                              ? 'Your note will be available for free to help other students'
                              : 'Enable to make your note a free donation',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isDonationMode ? Colors.green[600] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDonationMode,
                      onChanged: (value) {
                        setState(() {
                          _isDonationMode = value;
                          if (_isDonationMode) {
                            _priceCtrl.text = '0';
                          } else {
                            _priceCtrl.text = '49';
                          }
                        });
                      },
                      thumbColor: WidgetStateProperty.all(Colors.green[600]),
                      activeTrackColor: Colors.green[200],
                    ),
                  ],
                ),
              ),

              // Form Fields
              Formfield(
                controller: _titleCtrl,
                label: 'Note Title',
                hint: 'e.g., Data Structures Complete Notes',
                icon: Icons.title,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              
              Formfield(
                controller: _subjectCtrl,
                label: 'Subject',
                hint: 'e.g., Computer Science',
                icon: Icons.subject,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter subject' : null,
              ),
              
              if (!_isDonationMode)
                Formfield(
                  controller: _priceCtrl,
                  label: 'Price',
                  hint: 'Enter price in rupees',
                  icon: Icons.currency_rupee,
                  prefix: '₹ ',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || double.tryParse(v) == null) ? 'Please enter a valid price' : null,
                ),
              
              Formfield(
                controller: _descriptionCtrl,
                label: 'Description (Optional)',
                hint: 'Tell students what makes your notes special...',
                icon: Icons.description,
                textInputAction: TextInputAction.done,
              ),
              
              const SizedBox(height: 12),
              
              FileUpload(
                fileName: _pickedFileName,
                onTap: _pickFile,
              ),
              
              const SizedBox(height: 40),
              
              PremiumButton(
                text: _isUploading 
                  ? (_isDonationMode ? 'Donating...' : 'Publishing...')
                  : (_isDonationMode ? 'Donate Note' : 'Publish Note'),
                icon: _isUploading 
                  ? null 
                  : (_isDonationMode ? Icons.volunteer_activism : Icons.publish),
                isLoading: _isUploading,
                onPressed: _isUploading ? null : _submit,
              ),
              
              const SizedBox(height: 16),
              
              // Secondary Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your note will be reviewed and published within 24 hours',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}