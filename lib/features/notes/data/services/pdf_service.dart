import 'dart:convert';
import 'dart:io';

class PdfService {

  static Future<String> encodeFileToBase64(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw FileSystemException('File not found', filePath);
      }
      
      final bytes = await file.readAsBytes();
      
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      rethrow;
    }
  }

 
  static Future<File> decodeBase64ToFile(
    String base64String,
    String outputPath,
  ) async {
    try {
      final bytes = base64Decode(base64String);
      
      final file = File(outputPath);
      await file.writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      rethrow;
    }
  }

  static double getBase64SizeInMB(String base64String) {
    final bytes = base64String.codeUnits;
    return bytes.length / (1024 * 1024);
  }

  static Future<double> getFileSizeInMB(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return bytes.length / (1024 * 1024);
    } catch (e) {
      rethrow;
    }
  }

  static bool isPdfFile(String filePath) {
    return filePath.toLowerCase().endsWith('.pdf');
  }


  static String compressBase64(String base64String) {
    return base64String.replaceAll(RegExp(r'\s+'), '');
  }

  static String encodeBytesToBase64(List<int> bytes) {
    try {
      return base64Encode(bytes);
    } catch (e) {
      rethrow;
    }
  }

  static double getBytesSizeInMB(List<int> bytes) {
    return bytes.length / (1024 * 1024);
  }

  static bool isPdfBytes(List<int> bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 && 
           bytes[1] == 0x50 && 
           bytes[2] == 0x44 && 
           bytes[3] == 0x46;
  }
}
