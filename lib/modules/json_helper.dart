import "dart:convert";
import "package:flutter/services.dart";

Future<Map<String, dynamic>?> readJsonFile(String filePath) async {
  try {
    // Read the file content as a string
    final contents = await rootBundle.loadString(filePath);
    // Decode the JSON string into a Dart object (Map or List)
    final jsonResponse = jsonDecode(contents);
    
    return jsonResponse as Map<String, dynamic>;
  } catch (e) {
    print('Error reading file: $e');
  }
  return null;
}