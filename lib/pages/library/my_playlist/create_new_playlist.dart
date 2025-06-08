import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/playlist_model.dart';

class CreateNewPlaylist extends StatefulWidget {
  final PlaylistModel? playlist;
  const CreateNewPlaylist({super.key, this.playlist});

  @override
  State<CreateNewPlaylist> createState() => _CreateNewPlaylistState();
}

class _CreateNewPlaylistState extends State<CreateNewPlaylist> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.playlist?.title ?? '';
    _descriptionController.text = widget.playlist?.description ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _submit() async {
    try {
      if (_formKey.currentState!.validate()) {
        final title = _titleController.text.trim();
        final description = _descriptionController.text.trim();
        // TODO: select image for playlist
        final image = _selectedImage;

        if (widget.playlist == null) {
          log('ok');
          await getIt<ApiKit>().supabase.userPlaylist.createNewPlaylist(
            title: title,
            description: description,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist đã được tạo!')),
          );

          Navigator.pop(context, true);
        } else {
          await getIt<ApiKit>().supabase.userPlaylist.updatePlaylist(
            playlistId: widget.playlist!.id,
            title: title,
            description: description,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist đã được cập nhật!')),
          );

          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist == null ? 'Tạo Playlist Mới' : 'Chỉnh sửa'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                label: Text(
                  widget.playlist == null ? 'Tạo Playlist' : 'Cập nhật',
                ),
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
