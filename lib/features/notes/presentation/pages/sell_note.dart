import 'package:campus_notes_app/common_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../theme/app_theme.dart';
import '../../../../common_widgets/form_field.dart';
import '../../../../common_widgets/file_upload.dart';
import '../../../../common_widgets/button/main_button.dart';
import '../../../../constants/subject_constants.dart';
import '../controller/notes_controller.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '49');
  final _descriptionCtrl = TextEditingController();
  String? _pickedFileName;
  List<int>? _pickedFileBytes;
  bool _isDonationMode = false;
  String _selectedSubject = subjects[0];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Error: Could not read PDF file'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          return;
        }

        final fileSizeMB = file.bytes!.length / (1024 * 1024);
        if (fileSizeMB > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'File too large: ${fileSizeMB.toStringAsFixed(2)}MB (max 10MB)'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          return;
        }

        setState(() {
          _pickedFileName = file.name;
          _pickedFileBytes = file.bytes;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'PDF selected: ${file.name} 📄 (${fileSizeMB.toStringAsFixed(2)}MB)'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please attach a PDF file'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!mounted) return;

    final notesController = context.read<NotesController>();

    final success = await notesController.uploadNoteWithBytes(
      title: _titleCtrl.text.trim(),
      subject: _selectedSubject,
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      isDonation: _isDonationMode,
      price: _isDonationMode ? null : double.tryParse(_priceCtrl.text),
      fileName: _pickedFileName!,
      fileBytes: _pickedFileBytes!,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _isDonationMode
                    ? 'Note donated successfully! ❤️'
                    : 'Note published successfully! 🎉',
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      final error = notesController.error ?? 'Upload failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      notesController.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        text: 'Sell Note',
        usePremiumBackIcon: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Consumer<NotesController>(
          builder: (context, notesController, child) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                _isDonationMode
                                    ? 'Help Other Students'
                                    : 'Earn Money & Points',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isDonationMode
                                    ? '❤️ Share knowledge freely'
                                    : '💰 Earn 80% of sales + 5% bonus points',
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
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          _isDonationMode ? Colors.green[50] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isDonationMode
                            ? Colors.green[300]!
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isDonationMode
                                ? Colors.green[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.volunteer_activism_outlined,
                            color: _isDonationMode
                                ? Colors.green[600]
                                : Colors.grey[600],
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
                                  color: _isDonationMode
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isDonationMode
                                    ? 'Your note will be available for free to help other students'
                                    : 'Enable to make your note a free donation',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isDonationMode
                                      ? Colors.green[600]
                                      : Colors.grey[600],
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
                          thumbColor:
                              WidgetStateProperty.all(Colors.green[600]),
                          activeTrackColor: Colors.green[200],
                        ),
                      ],
                    ),
                  ),
                  Formfield(
                    controller: _titleCtrl,
                    label: 'Note Title',
                    hint: 'e.g., Data Structures Complete Notes',
                    icon: Icons.title,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.subject,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Subject',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSubject,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primary,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            items: subjects.map((String subject) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Row(
                                  children: [
                                    Icon(
                                      getSubjectIcon(subject),
                                      size: 20,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(subject),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedSubject = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isDonationMode)
                    Formfield(
                      controller: _priceCtrl,
                      label: 'Price',
                      hint: 'Enter price in rupees',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || double.tryParse(v) == null)
                              ? 'Please enter a valid price'
                              : null,
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
                  const SizedBox(height: 8),
                  if (notesController.uploadMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        notesController.uploadMessage!,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  PremiumButton(
                    text: notesController.isLoading
                        ? (_isDonationMode ? 'Donating...' : 'Publishing...')
                        : (_isDonationMode ? 'Donate Note' : 'Publish Note'),
                    icon: notesController.isLoading
                        ? null
                        : (_isDonationMode
                            ? Icons.volunteer_activism
                            : Icons.publish),
                    isLoading: notesController.isLoading,
                    onPressed: notesController.isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 16),
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
                            'Your PDF is encrypted and stored securely in the cloud.\n'
                            'Review & publishing within 24 hours.',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
