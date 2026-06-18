import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:option_context_menu/model/Product.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; 

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> listData = decodedData['data'] ?? [];
        return listData.map((dynamic item) => Product.fromJson(item)).toList();
      }
      throw Exception('Gagal memuat data');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Di dalam lib/service/api_service.dart

static Future<bool> addProduct(Map<String, String> fields, PlatformFile? pickedFile) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));
    request.fields.addAll(fields);

    if (pickedFile != null && pickedFile.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        pickedFile.bytes!,
        filename: pickedFile.name,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // KUNCI DEBUGGING:
    if (response.statusCode != 201 && response.statusCode != 200) {
      print("❌ ERROR SERVER: ${response.statusCode}");
      print("❌ PESAN LENGKAP: ${response.body}"); // INI AKAN MEMBERITAHU KITA ERRORNYA
      return false;
    }
    return true;
  } catch (e) {
    print("❌ EXCEPTION: $e");
    return false;
  }
}

  static Future<bool> updateProduct(int id, Map<String, String> fields, PlatformFile? pickedFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products/$id'));
      request.fields.addAll(fields);

      if (pickedFile != null && pickedFile.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          pickedFile.bytes!,
          filename: pickedFile.name,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
print("RESPONSE SERVER: ${response.statusCode}"); // Tambahkan ini
print("BODY SERVER: ${response.body}");           // Tambahkan ini

if (response.statusCode == 200) {
  return true;
} else {
  return false;
}
      return true;
    } catch (e) {
      throw Exception('Gagal mengupdate produk: $e');
    }
  }

  static Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}