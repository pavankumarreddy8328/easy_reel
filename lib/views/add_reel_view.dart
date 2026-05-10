import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reels_controller.dart';
import '../data/models/reel_model.dart';
import '../routes/app_pages.dart';

class AddReelView extends StatefulWidget {
  const AddReelView({Key? key}) : super(key: key);

  @override
  State<AddReelView> createState() => _AddReelViewState();
}

class _AddReelViewState extends State<AddReelView> {
  final _formKey = GlobalKey<FormState>();
  final _videoUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isYoutubeUrl = false.obs;
  final _isLoading = false.obs;

  @override
  void dispose() {
    _videoUrlController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateAndAddReel() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;

      final reel = Reel(
        id: '',
        videoUrl: _videoUrlController.text.trim(),
        username: _usernameController.text.trim(),
        description: _descriptionController.text.trim(),
        likes: 0,
        views: 0,
        isYoutubeUrl: _isYoutubeUrl.value,
        createdAt: DateTime.now(),
      );

      final controller = Get.find<ReelsController>();
      final success = await controller.addNewReel(reel);

      _isLoading.value = false;

      if (success) {
        Get.snackbar(
          'Success',
          'Reel added successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed(AppRoutes.reels);
      } else {
        Get.snackbar(
          'Error',
          'Failed to add reel',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Reel'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Information Card
              Card(
                color: Colors.blue.withAlpha(25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Supported Video Sources:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• YouTube URLs (e.g., https://www.youtube.com/watch?v=...)',
                        style: TextStyle(fontSize: 12),
                      ),
                      const Text(
                        '• Direct video URLs (MP4, WebM, etc.)',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Recommended: Use YouTube URLs for best compatibility',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Video URL Field
              _buildTextField(
                controller: _videoUrlController,
                label: 'Video URL *',
                hint: 'Enter YouTube or direct video URL',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Video URL is required';
                  }
                  if (!value!.contains('http')) {
                    return 'Enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // YouTube URL Toggle
              Obx(() => CheckboxListTile(
                value: _isYoutubeUrl.value,
                onChanged: (value) {
                  _isYoutubeUrl.value = value ?? false;
                },
                title: const Text('This is a YouTube URL'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              )),
              const SizedBox(height: 16),

              // Username Field
              _buildTextField(
                controller: _usernameController,
                label: 'Username *',
                hint: 'Enter your username',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Username is required';
                  }
                  if (value!.length < 2) {
                    return 'Username must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter a description for your reel (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Add Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      _isLoading.value ? null : _validateAndAddReel,
                  child: _isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Reel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),

              // Example URLs Section
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Example YouTube URLs:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildExampleUrl(
                'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
              ),
              _buildExampleUrl(
                'https://youtube.com/shorts/dQw4w9WgXcQ',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
    );
  }

  Widget _buildExampleUrl(String url) {
    return GestureDetector(
      onTap: () {
        _videoUrlController.text = url;
        _isYoutubeUrl.value = true;
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.copy, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
