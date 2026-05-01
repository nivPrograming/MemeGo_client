import "dart:convert";
import "package:flutter/services.dart";

Future<Map<String, dynamic>?> readJsonFile(String filePath) async {
  try {
    final contents = await rootBundle.loadString(filePath);
    
    final jsonResponse = jsonDecode(contents);
    
    return jsonResponse as Map<String, dynamic>;
  } catch (e) {
    print('Error reading file: $e');
  }
  return null;
}