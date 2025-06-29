import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/rating/bottom_sheet.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  final _picker = ImagePicker();
  final myProfile = getIt<ApiKit>().myProfile;
  late String avatarUrl = myProfile().avatarUrl;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        setState(() {
          isLoading = true;
        });

        await getIt<ApiKit>().setAvatar(File(image.path));

        if (mounted) {
          showSuccessSnackbar(
            context,
            message: 'Cập nhật ảnh đại diện thành công!',
          );
        }
        
        await CachedNetworkImage.evictFromCache(myProfile().avatarUrl);
        setState(() {
          isLoading = false;
          avatarUrl = myProfile().avatarUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(
          context,
          message: 'Có lỗi xảy ra khi cập nhật ảnh đại diện!',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradBackground2(
      imageUrl: myProfile().avatarUrl,
      builder: (_, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hồ sơ cá nhân'),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body:
              isLoading
                  ? const Center(
                    child: SpinKitDancingSquare(color: Colors.white),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildProfileInfo(),
                        const SizedBox(height: 24),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Chọn hình ảnh'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Chọn từ thư viện'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Chụp ảnh'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                    ),
              );
            },
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: myProfile().avatarUrl,
                fit: BoxFit.cover,
                errorWidget:
                    (context, url, error) => Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          myProfile().displayName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(myProfile().email, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Họ và tên'),
              subtitle: Text(myProfile().displayName),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editFullName,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(myProfile().email),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const FaIcon(FontAwesomeIcons.heart),
            label: const Text('Đánh giá chúng tôi!'),
            onPressed: () => showRatingBottomSheet(context),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  void _editFullName() {
    final TextEditingController nameController = TextEditingController(
      text: myProfile().displayName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sửa họ tên'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Họ và tên mới',
              border: OutlineInputBorder(),
            ),
            controller: nameController,
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final String newName = nameController.text.trim();

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Tên không được để trống')),
                  );
                  return;
                }

                if (newName == myProfile().displayName) {
                  Navigator.pop(dialogContext);
                  return;
                }

                Navigator.pop(dialogContext);

                // Hiển thị loading
                if (mounted) {
                  setState(() => isLoading = true);
                }

                try {
                  await getIt<ApiKit>().changeName(newName);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật tên thành công!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Có lỗi xảy ra: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } finally {
                  // Tắt trạng thái loading
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => _LogoutConfirmationDialog(
            onConfirm: () async => await _performLogout(context),
          ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      context.go('/signin');
      await getIt<ApiKit>().signOut();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Đăng xuất thất bại: $e')),
      );
    }
  }
}

class _LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _LogoutConfirmationDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đăng xuất'),
      content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
