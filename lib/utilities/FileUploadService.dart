import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadService {
  static Future<String?> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      var dio = Dio();
      // Update the URL to the endpoint where you are handling the file upload.
      String uploadUrl = 'http://yourserver.com/upload';

      try {
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        });

        var response = await dio.post(uploadUrl, data: formData);
        if (response.statusCode == 200) {
          // Assuming the server returns the URL of the uploaded file
          return response.data['fileUrl'];
        }
      } catch (e) {
        print(e);
        return null;
      }
    }
    return null;
  }
}
