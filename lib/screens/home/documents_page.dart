import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../../shared/constants/colors.dart';

class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  final List<String> _documents = [];
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    setState(() => _isUploading = true);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final fileName = result.files.single.name;

      // TODO: Replace with your API upload logic (e.g. S3 or other storage)
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: fileName),
      });
      final dio = Dio();
      final response = await dio.post(
        'YOUR_UPLOAD_ENDPOINT',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        ),
      );

      if (response.statusCode == 200) {
        final fileUrl = response.data['fileUrl'] as String;
        // TODO: Save fileUrl in HiSend via your CRUD endpoint
        setState(() {
          _documents.add(fileUrl);
        });
      }
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Documents', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUpload,
              icon: _isUploading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  final url = _documents[index];
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(url.split('/').last),
                    subtitle: Text(url),
                    onTap: () {
                      // TODO: Implement document preview (e.g. open URL)
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
