import 'package:flutter/material.dart';
import 'package:memecloud/apis/supabase/auth.dart';
import 'package:memecloud/core/getit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "Nguyễn Văn A";
  String email = "nguyenvana@example.com";
  bool isDarkMode = false;

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
      body: SingleChildScrollView(
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
            child: Image.network(
              'https://example.com/avatar.jpg', // Replace with your image URL
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
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
    showDialog(
      context: context,
      builder: (context) {
        String newName = fullName;
        return AlertDialog(
          title: const Text('Sửa họ tên'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Họ và tên mới'),
            controller: TextEditingController(text: fullName),
            onChanged: (value) => newName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  fullName = newName;
                });
                Navigator.pop(context);
                // Call your update function here
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
            onConfirm: () => _performLogout(context),
          ),
    );
  }

  void _performLogout(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      getIt<SupabaseAuthApi>().signOut();

      Navigator.pop(context); // Đóng loading
    } catch (e) {
      Navigator.pop(context); // Đóng loading
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Đăng xuất thất bại: ${e.toString()}')),
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
