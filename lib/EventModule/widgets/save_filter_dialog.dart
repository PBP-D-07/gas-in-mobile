import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class SaveFilterDialog extends StatefulWidget {
  final String? location;
  final String? category;
  final VoidCallback onSaved;

  const SaveFilterDialog({
    super.key,
    this.location,
    this.category,
    required this.onSaved,
  });

  @override
  State<SaveFilterDialog> createState() => _SaveFilterDialogState();
}

class _SaveFilterDialogState extends State<SaveFilterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveFilter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://localhost:8000/event/api/saved-search/create/',
        {
          'name': _nameController.text,
          'location': widget.location ?? '',
          'category': widget.category ?? '',
        },
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Current Filter'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berikan nama untuk kombinasi filter ini agar mudah diakses nanti',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Filter',
                hintText: 'e.g., Futsal Jakarta Pagi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama filter tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.location != null || widget.category != null) ...[
              const Text(
                'Filter yang akan disimpan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.location != null)
                Text('📍 Lokasi: ${widget.location}'),
              if (widget.category != null)
                Text('🏃 Kategori: ${_getCategoryLabel(widget.category!)}'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveFilter,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  String _getCategoryLabel(String category) {
    const categories = {
      'running': 'Lari',
      'badminton': 'Badminton',
      'futsal': 'Futsal',
      'football': 'Sepak Bola',
      'basketball': 'Basket',
      'cycling': 'Sepeda',
      'volleyball': 'Voli',
      'yoga': 'Yoga',
      'padel': 'Padel',
      'other': 'Lainnya',
    };
    return categories[category] ?? category;
  }
}