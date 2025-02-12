import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mscl_engineer/Controller/status_controller.dart';
import 'package:mscl_engineer/Model/api_url.dart';
import 'package:mscl_engineer/Model/complaintdetail.dart';
import 'package:mscl_engineer/Model/status.dart';

class GrievancePageController extends GetxController{
  List<Grievance> grievanceData = [];
  List<Grievance> filteredGrievanceData = [];
  final StatusController statusController = Get.put(StatusController());


    Future<void> fetchcomplaint() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userid = prefs.getString('userId');
    //final customer = _customerController.customer;
    
    try {
      final url = ApiUrl.getuserdata(userid!);
     // debugPrint('Fetching complaint data from URL: $url');

      final response = await http.get(
        Uri.parse(url),
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
       //   debugPrint('Decrypted user data: $decryptedData');

      
          
            grievanceData = decryptedJsonList.map((item) {
              return Grievance(
                grievanceId: item['grievance_id'],
                complaintTypeTitle: item['complaint_type_title'],
                deptName: item['dept_name'],
                zoneName: item['zone_name'],
                wardName: item['ward_name'],
                streetName: item['street_name'],
                pincode: item['pincode'],
                complaint: item['complaint'],
                complaintDetails: item['complaint_details'],
                publicUserId: item['public_user_id'],
                publicUserName: item['public_user_name'],
                phone: item['phone'],
                status: item['status'],
                statusflow: item['statusflow'],
                priority: item['priority'],
                lat: item['lat'],
                lon: item['lon'],
                createdAt: item['createdAt'],
                updatedAt: item['updatedAt'],
                assignUser: item['assign_user'],
                assignUsername: item['assign_username'],
                isEsacalted: item['isEsacalted'],
                isHighlighted: item['isHighlighted'],
                escalationnotify: item['escalation_notify'],
                escalationnotifyread: item['escalation_notify_read']

              );
            }).toList();
            // Filter the grievance data based on complaint type and status
            filterGrievanceData();
           // _userController.fetchUserData(userid);
          
        } catch (e) {
          debugPrint('Decryption failed: $e');
        }

      } else {
        debugPrint('Failed to fetch complaint data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HTTP request failed: $e');
    }
  }


void filterGrievanceData() {
  
    // When complaint type is "All", show all grievances initially without filtering by status
    if (selectedStatus == 'all' || selectedStatus == null) {
      filteredGrievanceData = grievanceData; // Show all data initially
    } 
    else{
      filteredGrievanceData = grievanceData
          .where((grievance) =>
              grievance.status.toLowerCase() == selectedStatus!.toLowerCase())
          .toList();
    }
  
    update();
    // Debug prints to check filtered data
   // debugPrint('Filtered grievance data: $filteredGrievanceData');
   // debugPrint('Selected Status: $selectedStatus');
  
  }



 List<StatusModel> statusList = [];
  String? selectedStatus;

void fetchStatusData() async {
  try {
    List<StatusModel> fetchedStatus = await statusController.getAllStatus();
      statusList = fetchedStatus;
      selectedStatus = null; // Initially set to null
  } catch (e) {
    // Handle error
    debugPrint('Error fetching status types: $e');
  }
}
}