import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';
import 'dart:developer' as developer;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "Nguyễn Văn A";
  String email = "nguyenvana@example.com";
  bool isDarkMode = false;
  bool isLoading = true;
  String? avatarUrl;
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    syncUserAccount(); // Gọi hàm khi widget được tạo
  }

  Future<void> syncUserAccount() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await getIt<ApiKit>().getProfile();

      result.fold(
        (error) {
          developer.log('Failed to get user account: $error');
          setState(() {
            errorMessage = error;
            isLoading = false;
          });
        },
        (userAccount) {
          setState(() {
            if (userAccount != null) {
              fullName = userAccount.displayName;
              email = userAccount.email;
              avatarUrl = userAccount.avatarUrl;
              developer.log('User account: $userAccount');
            } else {
              developer.log('User not found');
              errorMessage = "Không tìm thấy thông tin người dùng";
            }
            isLoading = false;
          });
        },
      );
    } catch (e, stackTrace) {
      developer.log(
        'Exception during syncUserAccount: $e',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        errorMessage = "Có lỗi xảy ra: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: _toggleDarkMode,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lỗi: $errorMessage',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: syncUserAccount,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildProfileInfo(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
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
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuAqi5s1FOI-T3qoE_2HD1avj69-gvq2cvIw&s', // Replace with your image URL
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
        const SizedBox(height: 16),
        Text(
          fullName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(email, style: Theme.of(context).textTheme.bodyMedium),
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
              subtitle: Text(fullName),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editFullName,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(email),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.lock),
            label: const Text('Đổi mật khẩu'),
            onPressed: _changePassword,
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

  // TODO: set dark mode
  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    // Implement your dark mode logic here
  }

  void _editFullName() {
    // Lưu context của màn hình chính (không phải context của dialog)
    final BuildContext mainContext = context;
    final TextEditingController nameController = TextEditingController(
      text: fullName,
    );

    showDialog(
      context: mainContext,
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

                // Validation
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Tên không được để trống')),
                  );
                  return;
                }

                // Nếu tên không thay đổi, đóng dialog và không làm gì
                if (newName == fullName) {
                  Navigator.pop(dialogContext);
                  return;
                }

                Navigator.pop(dialogContext); // Đóng dialog

                // Hiển thị loading
                if (mounted) {
                  setState(() {
                    isLoading = true;
                  });
                }

                try {
                  // Gọi API để cập nhật tên
                  final result = await getIt<ApiKit>().changeName(newName);

                  // Xử lý kết quả
                  if (mounted) {
                    result.fold(
                      (error) {
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          SnackBar(
                            content: Text('Cập nhật thất bại: $error'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        developer.log('Failed to update user name: $error');
                      },
                      (_) {
                        // Cập nhật state và hiển thị thông báo thành công
                        setState(() {
                          fullName = newName;
                        });
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật tên thành công'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(mainContext).showSnackBar(
                      SnackBar(
                        content: Text('Có lỗi xảy ra: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  developer.log(
                    'Exception during update name: $e',
                    error: e,
                    stackTrace: StackTrace.current,
                  );
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

  void _changePassword() {
    // Implement your change password logic here
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mật khẩu hiện tại'),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mật khẩu mới'),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Call your password change function here
              },
              child: const Text('Xác nhận'),
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
