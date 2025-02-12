import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mscl_engineer/Model/api_url.dart';
import 'package:mscl_engineer/Model/log_model.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

class ReplycomplaintController extends GetxController{
  
   List<LogDetail> logdetails = [];
  Future<void> fetchLogDetails(String grievanceId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final url = ApiUrl.grievlogget(grievanceId); // Replace with your API URL
     // debugPrint('Fetching log details from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        // Decryption key and IV
        final key = encrypt.Key.fromBase16(
            '9b7bdbd41c5e1d7a1403461ba429f2073483ab82843fe8ed32dfa904e830d8c9');
        final iv = encrypt.IV.fromBase16('33224fa12720971572d1a5677cede948');
        final encrypter = encrypt.Encrypter(
            encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

        try {
          // Decrypt the encrypted data
          final encryptedData = encrypt.Encrypted.fromBase16(json['data']);
          final decryptedData = encrypter.decrypt(encryptedData, iv: iv);
          List<dynamic> decryptedJsonList = jsonDecode(decryptedData);
     
            logdetails = decryptedJsonList.map((item)=>LogDetail.fromJson(item)).toList();

               logdetails.sort((a, b) => DateTime.parse(b.createdAt)
                .compareTo(DateTime.parse(a.createdAt)));
         
        } catch (e) {
          debugPrint('Decryption failed: $e');
        }
      } else {
        debugPrint('Failed to fetch log data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HTTP request failed: $e');
    }
  }
  

}