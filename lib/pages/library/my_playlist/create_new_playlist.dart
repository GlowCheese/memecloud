import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';

class CreateNewPlaylist extends StatefulWidget {
  const CreateNewPlaylist({super.key});

  @override
  State<CreateNewPlaylist> createState() => _CreateNewPlaylistState();
}

class _CreateNewPlaylistState extends State<CreateNewPlaylist> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final image = _selectedImage;

      getIt<ApiKit>().supabase.userPlaylist.createNewPlaylist(
        title: title,
        description: description,
      );

      // Hiển thị snackbar hoặc quay lại màn hình trước
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Playlist đã được tạo!')));

      Navigator.pop(context); // quay về trang trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Playlist Mới')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child:
                    _selectedImage != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _selectedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.white60,
                              size: 40,
                            ),
                          ),
                        ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tên Playlist',
                  labelStyle: TextStyle(color: Colors.white60),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nhập tên playlist'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  labelStyle: TextStyle(color: Colors.white60),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.playlist_add),
                label: const Text('Tạo Playlist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
