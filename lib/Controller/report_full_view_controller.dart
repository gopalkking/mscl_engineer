import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mscl_engineer/Model/api_url.dart';


class ReportFullViewController extends GetxController{
    // final List<Uint8List> imageBytesList = [];
    //   bool isLoading = true;
     // Using Rx types for reactivity
  RxList<Uint8List> imageBytesList = <Uint8List>[].obs;

  RxBool isLoading = true.obs;
     Future<void> fetchGrievancesimage(String grievid) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
     
  try {
    imageBytesList.clear();
    isLoading.value = true;
    update(); 
    final response = await http.get(
      Uri.parse(ApiUrl.imgget(grievid)),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      // Decryption key and IV
      final key = encrypt.Key.fromBase16('9b7bdbd41c5e1d7a1403461ba429f2073483ab82843fe8ed32dfa904e830d8c9');
      final iv = encrypt.IV.fromBase16('33224fa12720971572d1a5677cede948');
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

      try {
        // Decrypt the encrypted data
        final encryptedData = encrypt.Encrypted.fromBase16(json['data']);
        final decryptedData = encrypter.decrypt(encryptedData, iv: iv);
        List<dynamic> decryptedJsonList = jsonDecode(decryptedData);
         for (var item in decryptedJsonList) {
          String attachmentId = item['attachment'];
          // Fetch and display the image
          await fetchAndDisplayImage(attachmentId);
            await Future.delayed(const Duration(seconds: 2));
        }
        
          isLoading.value = false;
          update();
        
      } catch (e) {
      //  print('Decryption failed: $e');
      }

    } else {
    }
  } catch (e) {
   // print('HTTP request failed: $e');
  }
}


Future<void> fetchAndDisplayImage(String attachmentId) async {
    final url = ApiUrl.getfile(attachmentId);
    // Log the URL

    try {
      final response = await http.get(Uri.parse(url));


      if (response.statusCode == 200) {
        String? contentType = response.headers['content-type'];

        if (contentType == null || contentType == 'undefined') {
          contentType = 'image/jpeg'; 
        }

        if (contentType.startsWith('image/')) {
          // Add image bytes to list
        
          imageBytesList.add(response.bodyBytes);
         

          // Trigger rebuild
         
        } else {
        }
      } else {
      }
    } catch (e) {
    //  print('Image fetch failed: $e');
    }
  }
}
