import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../utils/cloudinary_config.dart';

/// ============================================================
/// CLOUDINARY SERVICE (user app)
/// ============================================================
/// Uploads images and videos to Cloudinary using an UNSIGNED
/// upload preset via the `auto` endpoint. Returns the secure
/// HTTPS URL. No SDK needed — plain multipart HTTP.
/// ============================================================
class CloudinaryService {
  /// Upload a single media file (image or video). Returns the secure_url.
  static Future<String> uploadMedia({
    required File file,
    String? folder,
  }) async {
    if (!isCloudinaryConfigured) {
      throw Exception(
        'Cloudinary not configured. Set kCloudinaryCloudName and '
        'kCloudinaryUploadPreset in utils/cloudinary_config.dart',
      );
    }

    final uri = Uri.parse(kCloudinaryUploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = kCloudinaryUploadPreset;
    if (folder != null) request.fields['folder'] = folder;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final url = data['secure_url'] as String?;
      if (url == null) {
        throw Exception('Cloudinary: no secure_url in response');
      }
      return url;
    } else {
      String message = 'Upload failed (${response.statusCode})';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = err['error']?['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Upload multiple files; returns the list of secure URLs (in order).
  static Future<List<String>> uploadAll(
    List<File> files, {
    String? folder,
  }) async {
    final urls = <String>[];
    for (final f in files) {
      urls.add(await uploadMedia(file: f, folder: folder));
    }
    return urls;
  }
}
