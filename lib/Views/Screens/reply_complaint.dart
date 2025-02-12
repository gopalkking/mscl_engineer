// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mscl_engineer/Controller/grievance_detail.dart';
import 'package:mscl_engineer/Controller/replycomplaint_controller.dart';
import 'package:mscl_engineer/Controller/report_full_view_controller.dart';
import 'package:mscl_engineer/Controller/similarrequest_controller.dart';
import 'package:mscl_engineer/Controller/status_controller.dart';
import 'package:mscl_engineer/Controller/user_attachment.dart';
import 'package:mscl_engineer/Model/api_url.dart';
import 'package:mscl_engineer/Model/log_model.dart';
import 'package:mscl_engineer/Model/status.dart';
import 'package:mscl_engineer/User%20preferences/customer_current.dart';
import 'package:mscl_engineer/Utils/Constant/app_pages_names.dart';
import 'package:mscl_engineer/Views/Screens/attachment.dart';
import 'package:mscl_engineer/Views/Screens/reports_full_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mscl_engineer/Views/Screens/similar_request.dart';
import 'package:mscl_engineer/Views/Screens/similar_request_item.dart';
import 'package:url_launcher/url_launcher.dart';

class ReplyComplaint extends StatefulWidget {
  final String grievid;
  final String status;
  final String username;
  final String comtitile;
  final String depart;
  final String complaindisc;
  final String createddate;
  final String createdtime;
  final String updatedate;
  final String pincode;
  final String ward;
  final String zone;
  final String street;
  final String phone;
  final String statusflow;
  final String assign;
  final Color statusLabel;
  final String status2;
  final String timeago;
  final String formateddate;
  final String formateddate2;
  final Color statusLabel2;
  final String complaint;
  final String lat;
  final String lon;
  final String? escalatednode;
  final String? escalatenotify;
  const ReplyComplaint(
      {super.key,
      required this.status,
      required this.username,
      required this.comtitile,
      required this.depart,
      required this.createddate,
      required this.updatedate,
      required this.ward,
      required this.zone,
      required this.street,
      required this.phone,
      required this.statusflow,
      required this.assign,
      required this.statusLabel,
      required this.status2,
      required this.statusLabel2,
      required this.grievid,
      required this.pincode,
      required this.timeago,
      required this.formateddate,
      required this.complaindisc,
      required this.createdtime,
      required this.formateddate2,
      required this.complaint,
      required this.lat,
      required this.lon, this.escalatednode, this.escalatenotify});

  @override
  State<ReplyComplaint> createState() => _ReplyComplaintState();
}

class _ReplyComplaintState extends State<ReplyComplaint> {
  bool _isBottomContainerVisible = false;
  bool _isBottomContainerVisible2 = false;
  bool _isStatusClosed = false;
 bool showContainer = true;
  late String selectedStatus = widget.status;
  final StatusController statusController = Get.put(StatusController());
  final TextEditingController _textController = TextEditingController();
  GrievanceController grievanceController = Get.put(GrievanceController());
   SimilarrequestController similarrequest = Get.put(SimilarrequestController());
   ReportFullViewController reportFullViewController = Get.put(ReportFullViewController());
   ReplycomplaintController replycomplaintController = Get.put(ReplycomplaintController());
        final PageController _pageController = PageController();
  final UserImageController userImageController =
      Get.put(UserImageController());
  final CustomerCurrentUser _customerController =
      Get.put(CustomerCurrentUser());


  List<LogDetail> logDetails = [];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.status;
    fetchStatusData();
    
    // fetchLogDetails(widget.grievid);
    replycomplaintController.fetchLogDetails(widget.grievid);
     similarrequest.fetchSimilarRequests(widget.zone, widget.ward, widget.street,
        widget.depart, widget.complaint, widget.grievid);
    userImageController.fetchLogAttachment(widget.grievid);
    reportFullViewController.fetchGrievancesimage(widget.grievid);
    _customerController.getUserInfo();
    if (selectedStatus.toLowerCase() == 'closed') {
      _isStatusClosed = true;
    }

  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _toggleBottomContainer2() {
    setState(() {
      _isBottomContainerVisible2 = !_isBottomContainerVisible2;
    });
  }

  void _toggleBottomContainer() {
    setState(() {
      _isBottomContainerVisible = !_isBottomContainerVisible;
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];

  void _showSimilarRequestsDialog(BuildContext context) {
    if (similarrequest.similarRequests.isEmpty) {
      Navigator.pushNamedAndRemoveUntil(context, AppPageNames.homeScreen, (route) => false);
      Fluttertoast.showToast(
        msg: "Submitted Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // // Map to track the status of each grievance (whether closed or not)
    // final Map<String, bool> closedStatusMap = {};

      Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => SimilarRequestsScreen(
        similarRequests: similarrequest.similarRequests,
        statusList: statusList,
        selectedFiles: _selectedFiles,
        textcontroller: _textController.text,
      )
    ), (route) => false

  );
 
  }


  Future<void> _pickFiles(bool fromCamera) async {
  try {
    if (fromCamera) {
      // Pick a single image from the camera
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
         if (_selectedFiles.length < 5) {
            setState(() {
              _selectedFiles.add(pickedFile);
            });
         }
         else {
            Fluttertoast.showToast(
              msg: 'You can only select up to 5 images in total',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 15.0,
            );
          }
      }
    } else {
      // Pick multiple images from the gallery
      final pickedFiles = await _picker.pickMultiImage();

      for (var file in pickedFiles) {
        final fileBytes = await file.readAsBytes();
        final fileSizeInKB = fileBytes.lengthInBytes / 1024;

        if (fileSizeInKB <= 400) {
          if (_selectedFiles.length < 5) {
            setState(() {
              _selectedFiles.add(file);
            });
          } else {
            Fluttertoast.showToast(
              msg: 'You can only select up to 5 images in total',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 15.0,
            );
            break;
          }
        } else {
          Fluttertoast.showToast(
            msg: 'File ${file.name} exceeds 400KB and was not added',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0,
          );
        }
      }
        }
  } catch (e) {
    debugPrint('Error picking files: $e');
  }
}


  void _showPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFiles(true); // Open camera
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFiles(false); // Open gallery
              },
            ),
          ],
        ),
      );
    },
  );
}


  Future<void> _uploadFiles(String grievanceId) async {
    if (_selectedFiles.isEmpty) return;

    final uri = Uri.parse(ApiUrl.replyComplainAttach);

    final request = http.MultipartRequest('POST', uri)
      ..fields['grievance_id'] = grievanceId
      ..fields['created_by_user'] = 'user';

    for (var file in _selectedFiles) {
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


  Future<void> _postStatusToApi2(String newStatus, String grievid) async {
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
    } else {}
    final response2 = await http.post(
      Uri.parse(ApiUrl.grievanceLog),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'grievance_id': widget.grievid,
        'log_details':
            "working is status : $newStatus update by  ${_customerController.customer.userName}"
      }),
    );
    if (response2.statusCode == 200) {
      _showSimilarRequestsDialog(context);
    } else {
      debugPrint('Second API call failed');
    }
  }

  

  List<StatusModel> statusList = [];
  String? _selectedStatus;

  void fetchStatusData() async {
    try {
      List<StatusModel> fetchedStatus = await statusController.getAllStatus();
      setState(() {
        statusList = fetchedStatus;
        _selectedStatus =
            statusList.isNotEmpty ? widget.status.toLowerCase() : null;
      });
    } catch (e) {
      // Handle error
      debugPrint('Error fetching status types: $e');
    }
  }

  Future<void> postData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final url = ApiUrl.replycomplain; // Replace with your API endpoint
    final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          "grievance_id": widget.grievid,
          "worksheet_name": _textController.text
        }));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Submitted Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (_selectedFiles.isNotEmpty) {
        await _uploadFiles(widget.grievid);
      }
      final secondResponse = await http.post(
        Uri.parse(ApiUrl.grievanceLog),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'grievance_id': widget.grievid,
          'log_details': "worksheet : ${_textController.text}"
        }),
      );

      if (secondResponse.statusCode == 200) {
        replycomplaintController.fetchLogDetails(widget.grievid);
      } else {
        // Handle error for the second API
        debugPrint('Failed to post data to the second API');
      }
    } else {
      // Handle error
      debugPrint('Failed to post data');
    }
  }




  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter = DateFormat('MMMM dd yyyy, hh:mm a');
    return formatter.format(dateTime);
  }

  String formatDay(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter = DateFormat('EEEE, dd MMMM');
    return formatter.format(dateTime);
  }

  String formatTime(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat timeFormatter = DateFormat('hh:mm a');
    return timeFormatter.format(dateTime);
  }

  String formatDatelog(String dateTime) {
    final DateFormat dateFormat = DateFormat('EEEE, dd MMMM');
    final DateTime date = DateTime.parse(dateTime).toLocal();
    return dateFormat.format(date);
  }

  String formatTimelog(String? createdString) {
    if (createdString != null) {
      DateTime createdAt = DateTime.parse(createdString).toLocal();
      return DateFormat('hh:mm a').format(createdAt);
    }
    return '';
  }

  void _launchURL(Uri uri, bool inapp) async {
    try {
      if (inapp) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      //print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 252, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
            color: Colors.black), // Ensure the drawer icon is visible
        title:  Text(
          AppLocalizations.of(context)!.replycomplaint,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0)]),
            height: 0.8,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.92,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white,boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 1.0)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.reqoverview,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Container(
                              height: 28,
                              width: 140,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 3.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      value: _selectedStatus?.toLowerCase(),
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.blue),
                                      isExpanded: true,
                                         items: [
                                            const DropdownMenuItem<String>(
                                            value: 'processing',
                                            enabled: false,
                                            child: Text('Processing'),
                                          ),
                                          ...statusList
                                              .map<DropdownMenuItem<String>>(
                                                  (StatusModel status) {
                                            return DropdownMenuItem<String>(
                                              value:
                                                  status.statusname.toLowerCase(),
                                             // enabled: !isDisabled,
                                              child: Text(status.statusname),
                                            );
                                          })
                                        ],
                                      onChanged: _isStatusClosed
                                          ? null
                                          : (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  selectedStatus = newValue;
                                                });
                                                if (_textController
                                                        .text.isEmpty ||
                                                    _selectedFiles.isEmpty) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Please enter text and select files before changing status.",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0,
                                                  );
                                                  return; // Exit if mandatory conditions are not met
                                                }
                                                // If the newValue is 'closed' and the text field is not empty
                                                if (newValue.toLowerCase() ==
                                                        'closed' &&
                                                    _textController
                                                        .text.isNotEmpty &&
                                                    _selectedFiles.isNotEmpty) {
                                                  postData();
                                                  _postStatusToApi2(
                                                      newValue, widget.grievid);
                                                  grievanceController.updateWorkSheetJE(widget.grievid,_textController.text);
                                                  _isStatusClosed = true;
                                                } else if (newValue
                                                        .toLowerCase() ==
                                                    'closed') {
                                                  // Show a warning toast if trying to select 'closed' without text
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Please enter text before selecting closed status",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0,
                                                  );
                                                } else if (newValue
                                                        .toLowerCase() !=
                                                    'new') {
                                                        postData();
                                                  _postStatusToApi2(
                                                      newValue, widget.grievid);
                                                  // For all other statuses except 'New', call _postStatusToApi()
                                                  // _postStatusToApi(
                                                  //     newValue, widget.grievid);
                                                }
                                              }
                                            }

                                      // underline: Container(),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.complainno,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const Spacer(),
                            Text(
                              widget.grievid,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.date,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const Spacer(),
                            Text(
                              widget.createddate,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500), //10
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.raiseby,
                              style: const TextStyle(
                                  fontSize: 14, //12
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const Spacer(),
                            widget.username.length > 10
    ? SizedBox(
        width: 90,
        child: Text(
          widget.username,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500),
          softWrap: true,
        ),
      )
    : Text(
        widget.username,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500),
        softWrap: true,
      ),

                          
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.department,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const Spacer(),

                          
                           widget.depart.length > 10
    ? SizedBox(
        width: 90,
        child: Text(
          widget.depart,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500),
          softWrap: true,
        ),
      )
    : Text(
        widget.depart,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500),
        softWrap: true,
      ),

                           
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  widget.escalatenotify == 'no' && showContainer?
                  Container(  
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8)
                    ),  
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [   
                        Text(widget.escalatednode.toString(),
                         style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                    softWrap: true,),
                       InkWell(
                        onTap: (){
                          setState(() {
                            showContainer = false; 
                          });
                          grievanceController.updateEscalationNotify(widget.grievid);
                        },
                        child: const Icon(Icons.cancel,color: Colors.white,size:26,)),
                      ],
                    ),
                    
                  ) : const SizedBox(),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                     
                      InkWell(
                        onTap: () =>
                            _launchURL(Uri.parse('tel:${widget.phone}'), false),
                        child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    Icons.call,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Call",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _launchURL(
                            Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${widget.lat},${widget.lon}'),
                            false),
                        child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "location",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )),
                      ),
                      
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: screenWidth * 0.9,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(244, 252, 255, 1),
                        boxShadow: [BoxShadow(color: Colors.grey)]),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context)!.grivedetail,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleBottomContainer2,
                          icon: Icon(_isBottomContainerVisible2
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                        )
                      ],
                    ),
                  ),
                  if (_isBottomContainerVisible2)
                    Container(
                      width: screenWidth * 0.9,
                      // height: screenHeight * 0.43,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white,boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 1.0)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.phonenum1,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.phone,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.address1,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.street,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.pincode,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.pincode,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.zone,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.zone,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.ward,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.ward,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.req,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.comtitile,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.department1,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  widget.depart,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReportsFullView(
                                            grievid: widget.grievid,
                                            status: widget.status,
                                            comtitile: widget.comtitile,
                                            depart: widget.depart,
                                            complaindisc: widget.complaindisc,
                                            pincode: widget.pincode,
                                            ward: widget.ward,
                                            zone: widget.zone,
                                            street: widget.street,
                                            phone: widget.phone,
                                            timeago: widget.timeago,
                                          )),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.reqfullview,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                  // const SizedBox(
                  //   height: 15,
                  // ),
                  Container(
                    width: screenWidth * 0.9,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(244, 252, 255, 1),
                        boxShadow: [BoxShadow(color: Colors.grey)]),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context)!.complainhis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        const SizedBox(
                          width: 3,
                        ),
                        Text("#${widget.grievid}",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54)),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleBottomContainer,
                          icon: Icon(_isBottomContainerVisible
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                        )
                      ],
                    ),
                  ),
                  if (_isBottomContainerVisible)
                    // Display additional data after all log details
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: Colors.white,boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 1.0)]),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (replycomplaintController.logdetails.isNotEmpty) ...[
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: replycomplaintController.logdetails.length +
                                              1, // +1 to include additional data after log details
                                          itemBuilder: (context, index) {
                                            if (index < replycomplaintController.logdetails.length) {
                                              // Display log details
                                              final log = replycomplaintController.logdetails[index];
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    formatDatelog(
                                                        log.createdAt),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          formatTimelog(
                                                              log.createdAt),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 40),
                                                        Container(
                                                          height: 25,
                                                          width: 1.5,
                                                          color: Colors.black,
                                                        ),
                                                        const SizedBox(
                                                            width: 30),
                                                        Expanded(
                                                          child: Text(
                                                            log.logMessage,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return null;
                                          }),
                                      if (userImageController
                                          .logDetails.isNotEmpty) ...[
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: userImageController
                                                    .logDetails.length +
                                                1, // +1 to include additional data after log details
                                            itemBuilder: (context, index) {
                                              if (index <
                                                  userImageController
                                                      .logDetails.length) {
                                                // Display log details
                                                final log = userImageController
                                                    .logDetails[index];

                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      formatDatelog(
                                                          log.createdAt),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            formatTimelog(
                                                                log.createdAt),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 40),
                                                          Container(
                                                            height: 25,
                                                            width: 1.5,
                                                            color: Colors.black,
                                                          ),
                                                          const SizedBox(
                                                              width: 30),
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                AttachmentPage(attachment: log.attachment)));
                                                              },
                                                              child: Text(
                                                                "Attachment: ${log.attachment}",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              return null;
                                            })
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (widget.formateddate.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                widget.formateddate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (widget.createdtime.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    logDetailRow(widget.createdtime,
                                        "Ticket Raised- ${widget.grievid}"),
                                    const SizedBox(height: 10),
                                    logDetailRow(widget.createdtime,
                                        "Assigned to particular ${widget.depart} department"),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.status,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      decoration: const BoxDecoration(
                                          color: Color.fromRGBO(0, 63, 91, 1)),
                                      child: Center(
                                        child: Text(
                                          widget.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                    Stack(
                      children: [
                        Obx(() {
                                        if (reportFullViewController.isLoading.value) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else if (reportFullViewController.imageBytesList.isNotEmpty) {
                                          return SizedBox(
                        height: 410.0,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: reportFullViewController.imageBytesList.length,
                          itemBuilder: (context, index) {
                            return OrientationBuilder(
                              builder: (context,orientation) {
                                return InstaImageViewer(
                                  child: Image.memory(
                                    reportFullViewController.imageBytesList[index],
                                      fit: BoxFit.contain,
                                                           width: orientation == Orientation.portrait
                                                            ? MediaQuery.of(context).size.width
                                                            : MediaQuery.of(context).size.height,
                                  ),
                                );
                              }
                            );
                          },
                        ),
                                          );
                                        } else {
                                          return 
                         Image.asset(
                        "assets/images/report.png",
                        fit: BoxFit.cover,
                        height: 410.0,
                        width: double.infinity,
                                          );
                                        
                                        }
                                      }),
                                        Obx(() {
                return reportFullViewController.imageBytesList.isNotEmpty
                    ? Positioned(
                        right: 0,
                        left: 10,
                        top: 380,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: reportFullViewController.imageBytesList.length,
                            effect: const ScrollingDotsEffect(
                              activeDotColor: Colors.blue,
                              dotColor: Colors.grey,
                              dotHeight: 8.0,
                              dotWidth: 8.0,
                              spacing: 8.0,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }),
              
                      ],
                    ),      
                   const SizedBox(
                    height: 10,
                  ),

                  Container(
                    width: screenWidth * 0.9,
                    color: Colors.white,
                    //  padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                         Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.similarreq,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        similarrequest.similarRequests.isEmpty
                            ? const Center(
                                child: Text('No similar requests found'))
                            : 
                            FutureBuilder(
                             future: similarrequest.fetchSimilarRequests(
                                    widget.zone,
                                    widget.ward,
                                    widget.street,
                                    widget.depart,
                                    widget.complaint,
                                    widget.grievid) ,

                              builder: (context,snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(child: CircularProgressIndicator());
                        } else if(snapshot.hasError){
                          return Center(child: Text('Error :${snapshot.hasError}'));
                        }else {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: similarrequest.similarRequests.length,
                                    itemBuilder: (context, index) {

                                      final request = similarrequest.similarRequests[index];
                                      
                                      return SimilarRequestItem(
                                        isLastItem:
                                            index == similarrequest.similarRequests.length - 1,
                                        grievid: request.grievanceId,
                                        status: request.status,
                                        dateandtime: formatDate(request.createdAt),
                                      );
                                    },
                                  );
                              }
                              }
                            ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5.0)
            .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: _selectedFiles.isNotEmpty ? 150 : 90,
          child: BottomAppBar(
            child: Column(
              children: [
                Visibility(
                  visible: _selectedFiles.isNotEmpty,
                  child: Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                          leading: const Icon(Icons.file_present),
                          title: Text(_selectedFiles[index].name),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () => _removeFile(index),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: (){
                            _showPicker(context);
                          },
                          icon: const Icon(Icons.image),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: 'Type...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (_textController.text.isNotEmpty) {
                              await postData();
                              if (selectedStatus == 'closed') {
                                _postStatusToApi2(
                                    selectedStatus, widget.grievid);
                                 grievanceController.updateWorkSheetJE(widget.grievid,_textController.text);
                              }
                              _textController.clear();
                              _selectedFiles.clear();
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please enter text",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logDetailRow(String time, String message) {
    return Row(
      children: [
        Text(
          time,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(width: 40),
        Container(
          height: 25,
          width: 1.5,
          color: Colors.black,
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
