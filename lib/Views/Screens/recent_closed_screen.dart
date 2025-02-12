import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mscl_engineer/Controller/grievance_page_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mscl_engineer/Views/Screens/allitem.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mscl_engineer/Views/Screens/reply_complaint.dart';

class RecentClosedScreen extends StatefulWidget {
  const RecentClosedScreen({super.key});

  @override
  State<RecentClosedScreen> createState() => _RecentClosedScreenState();
}

class _RecentClosedScreenState extends State<RecentClosedScreen> {
  final TextEditingController _searchController = TextEditingController();

  final GrievancePageController grievancepage =
      Get.put(GrievancePageController());

  @override
  void initState() {
    super.initState();
    grievancepage.fetchcomplaint();
    grievancepage.fetchStatusData();
    _searchController.addListener(() {
      _filterGrievanceData1();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterGrievanceData1() {
    setState(() {
      final searchQuery = _searchController.text.toLowerCase();

      grievancepage.filteredGrievanceData =
          grievancepage.grievanceData.where((grievance) {
        // Check if the search term matches any of the fields
        final matchesSearch = searchQuery.isEmpty ||
            grievance.grievanceId.toLowerCase().contains(searchQuery) ||
            grievance.phone.toLowerCase().contains(searchQuery);

        // Check if the grievance matches the selected status
        final matchesStatus = grievancepage.selectedStatus == null ||
            grievance.status.toLowerCase() ==
                grievancepage.selectedStatus!.toLowerCase();

        return matchesSearch && matchesStatus;
      }).toList();
    });
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

  String formatTimeAgo(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return timeago.format(dateTime);
  }

  int maxCount = 10;
  @override
  Widget build(BuildContext context) {

         String recentclosed = AppLocalizations.of(context)!.recentclosed;
    return GetBuilder(
        init: grievancepage,
        builder: (context) {
          final filteredData = grievancepage.filteredGrievanceData
              .where((grievance) => grievance.status == 'closed')
              .toList()
            ..sort((a, b) => DateTime.parse(b.createdAt)
                .compareTo(DateTime.parse(a.createdAt)));

          final displayedData = _searchController.text.isEmpty
              ? filteredData.take(maxCount).toList()
              : filteredData;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                 Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recentclosed,
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                // if (grievancepage.filteredGrievanceData.isNotEmpty)
                displayedData.isEmpty
                    ? const Center(child: Text('No grievances to display'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemCount: displayedData.length,
                        itemBuilder: (context, index) {
                          final grievance = displayedData[index];
                          final String formattedDate =
                              formatDate(grievance.createdAt);
                          final String timeago =
                              formatTimeAgo(grievance.createdAt);
                          final String formattedTime =
                              formatTime(grievance.createdAt);
                          final String formattedTime2 =
                              formatTime(grievance.updatedAt);
                          final String formattedday2 =
                              formatDay(grievance.updatedAt);
                          final String formattedday =
                              formatDay(grievance.createdAt);
                          return AllList(
                            statusLabel: _getStatusColor(grievance.status),
                            containerColor: grievance.isEsacalted == 'yes'
                                ? Colors.red.withOpacity(0.25)
                                : grievance.isHighlighted == 'yes'
                                    ? Colors.yellowAccent.withOpacity(0.25)
                                    : Colors.white,
                            status: grievance.status,
                            status2: grievance.priority,
                            statusLabel2: _getStatusColor2(grievance.priority),
                            username: grievance.publicUserName,
                            comtitile: grievance.complaintTypeTitle,
                            createddate: grievance.createdAt,
                            assign: grievance.assignUsername,
                            depart: grievance.deptName,
                            phone: grievance.phone,
                            statusflow: grievance.statusflow,
                            street: grievance.streetName,
                            updatedate: grievance.updatedAt,
                            ward: grievance.wardName,
                            zone: grievance.zoneName,
                            grievid: grievance.grievanceId,
                            pincode: grievance.pincode,
                            complaindisc: grievance.complaintDetails,
                            complaint: grievance.complaint,
                            lat: grievance.lat.toString(),
                            lon: grievance.lon.toString(),
                            icon: grievance.escalationnotifyread == 'no'
                                ? const Icon(
                                    Icons.chat,
                                    size: 30,
                                    color: Colors.red,
                                  )
                                : const SizedBox(),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReplyComplaint(
                                            status: grievance.status,
                                            username: grievance.publicUserName,
                                            comtitile:
                                                grievance.complaintTypeTitle,
                                            depart: grievance.deptName,
                                            createddate: formattedDate,
                                            updatedate: formattedTime2,
                                            ward: grievance.wardName,
                                            zone: grievance.zoneName,
                                            street: grievance.streetName,
                                            phone: grievance.phone,
                                            statusflow: grievance.statusflow,
                                            assign: grievance.assignUsername,
                                            statusLabel: _getStatusColor(
                                                grievance.status),
                                            status2: grievance.priority,
                                            statusLabel2: _getStatusColor2(
                                                grievance.priority),
                                            grievid: grievance.grievanceId,
                                            pincode: grievance.pincode,
                                            complaindisc:
                                                grievance.complaintDetails,
                                            timeago: timeago,
                                            createdtime: formattedTime,
                                            formateddate: formattedday,
                                            formateddate2: formattedday2,
                                            complaint: grievance.complaint,
                                            lat: grievance.lat.toString(),
                                            lon: grievance.lon.toString(),
                                            escalatednode:
                                                grievance.escalationnotify,
                                            escalatenotify:
                                                grievance.escalationnotifyread,
                                          )));
                            },
                          );
                        },
                      )
                // : const Center(child: Text('No grievances to display')),
              ],
            ),
          );
        });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.green;
      case 'new':
        return Colors.blue;
      case 'Closed':
        return const Color.fromRGBO(0, 63, 91, 1);
      case 'On Hold':
        return Colors.blue;
      case 'Resolved':
        return Colors.green.shade900;
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor2(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.green;
      case 'Critical':
        return Colors.blue;
      case 'Medium':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }
}
