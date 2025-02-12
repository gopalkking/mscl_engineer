import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mscl_engineer/Model/api_url.dart';
import 'package:mscl_engineer/Model/similar_request.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

class SimilarrequestController extends GetxController {
     List<SimilarRequest> similarRequests = [];

   Future<void> fetchSimilarRequests(
      String zone,String ward,String street,String depart,String complaint,String grievid
    ) async {
  
    final queryParams = {
      'zone_name': zone,
      'ward_name': ward,
      'street_name': street,
      'dept_name': depart,
      'complaint': complaint,
    };

    final uri =
        Uri.parse(ApiUrl.similarrequest).replace(queryParameters: queryParams);
   // debugPrint('Request URI: $uri');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken'); 

    // Encryption key and IV
    final key = encrypt.Key.fromBase16(
        '9b7bdbd41c5e1d7a1403461ba429f2073483ab82843fe8ed32dfa904e830d8c9');
    final iv = encrypt.IV.fromBase16('33224fa12720971572d1a5677cede948');
    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        try {
          // Assuming the response data needs decryption
          final encryptedData = encrypt.Encrypted.fromBase16(json['data']);
          final decryptedData = encrypter.decrypt(encryptedData, iv: iv);
          final List<dynamic> decryptedJsonList = jsonDecode(decryptedData);
           // debugPrint('Fetching Similar details from : $decryptedJsonList');
      
            final filteredRequests = decryptedJsonList
            .where((item) => item['grievance_id'] != grievid)
            .toList();
  similarRequests =
              filteredRequests.map((item) => SimilarRequest.fromJson(item)).toList();
              
        } catch (e) {
          debugPrint('Decryption failed: $e');
        }
      } else {
        debugPrint("Failed to fetch similar requests: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Network or other error: $e");
    }
  }
  

}