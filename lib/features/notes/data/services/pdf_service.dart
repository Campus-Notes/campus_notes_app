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

  /// Count the number of pages in a PDF by counting page objects
  /// This is a simple heuristic that counts "/Page" occurrences
  static int countPdfPages(List<int> pdfBytes) {
    try {
      // Convert bytes to string to search for page markers
      final pdfString = String.fromCharCodes(pdfBytes);
      
      // Count occurrences of "/Type /Page" (not /Pages which is the parent)
      // This regex looks for "/Type" followed by whitespace and "/Page" but not "/Pages"
      final pagePattern = RegExp(r'/Type\s*/Page(?![s/])');
      final matches = pagePattern.allMatches(pdfString);
      
      int pageCount = matches.length;
      
      // If no pages found using strict pattern, try counting /Page with word boundary
      if (pageCount == 0) {
        final simplePagePattern = RegExp(r'/Page\b');
        pageCount = simplePagePattern.allMatches(pdfString).length;
        // Subtract 1 if we found /Pages (parent object)
        if (pdfString.contains('/Pages')) {
          pageCount = pageCount > 0 ? pageCount - 1 : 0;
        }
      }
      
      return pageCount > 0 ? pageCount : 1; // Return at least 1 page
    } catch (e) {
      // If counting fails, return 1 as default
      return 1;
    }
  }
}
