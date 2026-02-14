import "dart:convert";
import "dart:io";

Future<Map<String, dynamic>?> readJsonFile(String filePath) async {
  try {
    final file = File(filePath);
    // Read the file content as a string
    final contents = await file.readAsString();
    // Decode the JSON string into a Dart object (Map or List)
    final jsonResponse = jsonDecode(contents);
    
    return jsonResponse as Map<String, dynamic>;
  } catch (e) {
    print('Error reading file: $e');
  }
  return null;
}