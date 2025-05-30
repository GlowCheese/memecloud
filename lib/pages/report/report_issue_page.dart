import 'package:flutter/material.dart';

class ReportIssueScreen extends StatefulWidget {
  @override
  _ReportIssueScreenState createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();

  String _selectedType = 'Lỗi';
  final List<String> _reportTypes = ['Lỗi', 'Đóng góp', 'Khác'];

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      final String type = _selectedType;
      final String content = _contentController.text;

      // Thực hiện gửi report (ví dụ: gửi lên Supabase, Firebase, hoặc server)
      print('Loại: $type');
      print('Nội dung: $content');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cảm ơn bạn đã gửi phản hồi!')),
      );

      _contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Báo cáo sự cố')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Loại báo cáo', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _reportTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              Text('Nội dung', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Mô tả chi tiết về lỗi hoặc góp ý...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập nội dung.';
                  }
                  return null;
                },
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitReport,
                  icon: Icon(Icons.send),
                  label: Text('Gửi báo cáo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
