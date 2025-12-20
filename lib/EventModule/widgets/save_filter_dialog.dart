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
      print('Saving filter with data:');
      print('Name: ${_nameController.text}');
      print('Location: ${widget.location ?? ""}');
      print('Category: ${widget.category ?? ""}');

      final response = await request.post(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/event/api/saved-search/create/',
        {
          'name': _nameController.text.trim(),
          'location': widget.location ?? '',
          'category': widget.category ?? '',
        },
      );

      print('Response from save: $response');

      if (mounted) {
        Navigator.pop(context);

        if (response != null &&
            (response['message'] == 'Saved search created successfully' ||
                response['status'] == 'success')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Filter berhasil disimpan!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          widget.onSaved();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menyimpan: ${response?['message'] ?? 'Unknown error'}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving filter: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getCategoryLabel(String category) {
    const categories = {
      'running': 'Lari',
      'badminton': 'Badminton',
      'futsal': 'Futsal',
      'football': 'Sepak Bola',
      'basketball': 'Basket',
      'cycling': 'Bersepeda',
      'volleyball': 'Voli',
      'yoga': 'Yoga',
      'padel': 'Padel',
      'other': 'Lainnya',
    };
    return categories[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Save Current Filter',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berikan nama untuk kombinasi filter ini agar mudah diakses nanti',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Filter',
                labelStyle: const TextStyle(color: Colors.deepPurple),
                hintText: 'e.g., Futsal Jakarta Pagi',
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.deepPurpleAccent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(
                  Icons.bookmark_border,
                  color: Colors.deepPurple,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama filter tidak boleh kosong';
                }
                if (value.trim().length < 3) {
                  return 'Nama filter minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.location != null || widget.category != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter yang akan disimpan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.location != null && widget.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lokasi: ${widget.location}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    if (widget.category != null && widget.category!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.sports,
                            size: 16,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kategori: ${_getCategoryLabel(widget.category!)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tidak ada filter aktif',
                        style: TextStyle(fontSize: 13, color: Colors.orange),
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveFilter,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
