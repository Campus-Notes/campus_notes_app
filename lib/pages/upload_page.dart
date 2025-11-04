import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
  String? _pickedFileName;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _pickFile() async {
    setState(() => _pickedFileName = 'notes.pdf');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Picked file: notes.pdf ')));
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _pickedFileName != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded note ')));
    } else if (_pickedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please attach your file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Discrete Math Problem Set'),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(labelText: 'Subject', hintText: 'e.g., Math'),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter subject' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid price' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.attach_file, color: AppColors.primary),
                ),
                title: Text(_pickedFileName ?? 'Attach PDF/DOCX/PPT'),
                trailing: TextButton(onPressed: _pickFile, child: const Text('Choose')),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: const Text('Publish Note')),
            ],
          ),
        ),
      ),
    );
  }
}
