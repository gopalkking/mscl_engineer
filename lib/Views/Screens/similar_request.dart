import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mscl_engineer/Controller/grievance_detail.dart';
import 'package:mscl_engineer/Model/api_url.dart';
import 'package:mscl_engineer/Model/similar_request.dart';
import 'package:mscl_engineer/Model/status.dart';
import 'package:mscl_engineer/User%20preferences/customer_current.dart';
import 'package:http/http.dart' as http;
import 'package:mscl_engineer/Utils/Constant/app_pages_names.dart';
import 'package:mscl_engineer/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SimilarRequestsScreen extends StatefulWidget {
  final String textcontroller;
  final List<XFile> selectedFiles;
  final List<SimilarRequest> similarRequests; // Replace with your actual model
  final List<StatusModel> statusList;

  const SimilarRequestsScreen({
    super.key,
    required this.similarRequests,
    required this.statusList,
    required this.selectedFiles,
    required this.textcontroller,
  });

  @override
  State<SimilarRequestsScreen> createState() => _SimilarRequestsScreenState();
}

class _SimilarRequestsScreenState extends State<SimilarRequestsScreen> {
  String? selectedBulkStatus; // Dropdown value for bulk update
  final Map<String, bool> selectedRequests = {}; // Tracks selected requests
  GrievanceController grievanceController = Get.put(GrievanceController());

  @override
  void initState() {
    super.initState();
    // Initialize all checkboxes as false
    for (var request in widget.similarRequests) {
      selectedRequests[request.grievanceId] = false;
    }
  }

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter = DateFormat('MMMM dd yyyy, hh:mm a');
    return formatter.format(dateTime);
  }

  final CustomerCurrentUser _customerController =
      Get.put(CustomerCurrentUser());

  void _updateSelectedStatuses() {
    if (selectedBulkStatus == null) {
      Fluttertoast.showToast(
        msg: "Please select a status to update",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final selectedIds = selectedRequests.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIds.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select at least one grievance",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    for (var request in widget.similarRequests) {
      if (selectedIds.contains(request.grievanceId)) {
        setState(() {
          request.status = selectedBulkStatus!;
        });

        // Call the API to update status
        postData2(request.grievanceId);
        _postStatusToApi3(selectedBulkStatus!, request.grievanceId);
        if (selectedBulkStatus == 'closed') {
          grievanceController.updateWorkSheetJE(request.grievanceId,widget.textcontroller);
        }
      }
    }

    

    Fluttertoast.showToast(
      msg: "Status updated for selected grievances",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _postStatusToApi3(String newStatus, String grievid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.post(
      Uri.parse(ApiUrl.updatestatus(grievid)),
      body: jsonEncode({
        'status': newStatus,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //  Navigator.pushNamedAndRemoveUntil(context, AppPageNames.homeScreen,(route)=> false);
    } else {}
    final response2 = await http.post(
      Uri.parse(ApiUrl.grievanceLog),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'grievance_id': grievid,
        'log_details':
            "working is status : $newStatus update by  ${_customerController.customer.userName}"
      }),
    );
    if (response2.statusCode == 200) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppPageNames.homeScreen, (route) => false);
    } else {
      debugPrint('Second API call failed');
    }
  }

  Future<void> postData2(String grievid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final url = ApiUrl.replycomplain; // Replace with your API endpoint
    final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          "grievance_id": grievid,
          "worksheet_name": widget.textcontroller
        }));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Sumitted Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (widget.selectedFiles.isNotEmpty) {
        await _uploadFiles(grievid);
      }
      final secondResponse = await http.post(
        Uri.parse(ApiUrl.grievanceLog),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'grievance_id': grievid,
          'log_details': "worksheet : ${widget.textcontroller}"
        }),
      );

      if (secondResponse.statusCode == 200) {
        //fetchLogDetails(grievid);
      } else {
        // Handle error for the second API
        debugPrint('Failed to post data to the second API');
      }
    } else {
      // Handle error
      debugPrint('Failed to post data');
    }
  }

  Future<void> _uploadFiles(String grievanceId) async {
    if (widget.selectedFiles.isEmpty) return;

    final uri = Uri.parse(ApiUrl.replyComplainAttach);

    final request = http.MultipartRequest('POST', uri)
      ..fields['grievance_id'] = grievanceId
      ..fields['created_by_user'] = 'user';

    for (var file in widget.selectedFiles) {
      final multipartFile =
          await http.MultipartFile.fromPath('files', file.path);
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:  Text(AppLocalizations.of(context)!.complainhis),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              dialogBox(context, "Alert", "Are you sure want to close?", '',(){
              Navigator.pushNamedAndRemoveUntil(
          context, AppPageNames.homeScreen, (route) => false);
              } , 'Cancel', 'Ok');
            },
            style: IconButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 215, 229, 241),
              padding: const EdgeInsets.only(left: 10),
            ),
          ),
        ),
        body: Column(children: [
          // Dropdown for bulk update
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(fontSize: 22),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 35,
                  width: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 3.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBulkStatus,
                        hint: const Text('Select status'),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBulkStatus = newValue;
                          });
                          
                        },
                        items: widget.statusList.map<DropdownMenuItem<String>>(
                          (StatusModel status) {
                            return DropdownMenuItem<String>(
                              value: status.statusname.toLowerCase(),
                              child: Text(status.statusname),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maincolor, // blue background color

                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _updateSelectedStatuses,
                  child: const Text(
                    'Update Status',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // List of similar requests with checkboxes
          Expanded(
            child: ListView.builder(
                itemCount: widget.similarRequests.length,
                itemBuilder: (context, index) {
                  final request = widget.similarRequests[index];
                  final String formattedDate = formatDate(request.createdAt);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: ExpansionTile(
                      leading: Checkbox(
                        value: selectedRequests[request.grievanceId],
                        onChanged: (bool? value) {
                          setState(() {
                            selectedRequests[request.grievanceId] =
                                value ?? false;
                          });
                        },
                      ),
                      title: Text('Grievance ID: ${request.grievanceId}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Current Status: ",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: Center(
                                        child: Text(
                                      request.status,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                  // Expanded(
                                  //   child: DropdownButton<String>(
                                  //     value: request.status,
                                  //     isExpanded: true,
                                  //     onChanged: (String? newValue) {
                                  //       if (newValue != null) {
                                  //         setState(() {
                                  //           request.status = newValue;
                                  //         });

                                  //         // Call the API to update status
                                  //        // _postStatusToApi(newValue, request.grievanceId);
                                  //       }
                                  //     },
                                  //     items: widget.statusList
                                  //         .map<DropdownMenuItem<String>>((StatusModel status) {
                                  //       return DropdownMenuItem<String>(
                                  //         value: status.statusname.toLowerCase(),
                                  //         child: Text(status.statusname),
                                  //       );
                                  //     }).toList(),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Text(
                                    "Description: ",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    request.complaindisc,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Text(
                                    "Department: ",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    request.deptname,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Text(
                                    "Date: ",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          )
        ]));
  }
  
   dialogBox(BuildContext context,String title,String desc,String image,void Function()? onchanged,
   String canceltext,String continueText) {
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kbackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.announcement_outlined,size: 50,),
             //  SvgPicture.asset(image,height: 50,width: 50,),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 16.0),
               Text(
                desc,
              
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 OutlinedButton(onPressed: (){
                   Navigator.pop(context);
                 },  style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red, 
         padding: const EdgeInsets.symmetric(horizontal: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: const BorderSide(color: Colors.red),
      ),
      child:  Text(
        canceltext,  
        style: const TextStyle(
          color: Colors.red,
          fontSize: 13,
        ),
      ),),
                 ElevatedButton(
                  onPressed: onchanged,style: ElevatedButton.styleFrom(
                  backgroundColor: maincolor, // blue background color
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),  
                ),
                child:Text(continueText,style:  const TextStyle(color: Colors.white,fontSize: 14),),)
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
