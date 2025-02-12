class Grievance {

  final String grievanceId;
  final String complaintTypeTitle;
  final String deptName;
  final String zoneName;
  final String wardName;
  final String streetName;
  final String pincode;
  final String complaint;
  final String complaintDetails;
  final String publicUserId;
  final String publicUserName;
  final String phone;
  final String status;
  final String statusflow;
  final String priority;
   String? lat;
   String? lon;
  final String createdAt;
  final String updatedAt;
  final String assignUser;
  final String assignUsername;
  final String? isHighlighted;
  final String? isEsacalted;
  final String? escalationnotify;
  final String? escalationnotifyread;

  Grievance({

    required this.grievanceId,
    required this.complaintTypeTitle,
    required this.deptName,
    required this.zoneName,
    required this.wardName,
    required this.streetName,
    required this.pincode,
    required this.complaint,
    required this.complaintDetails,
    required this.publicUserId,
    required this.publicUserName,
    required this.phone,
    required this.status,
    required this.statusflow,
    required this.priority,
     this.lat,
     this.lon,
    required this.createdAt,
    required this.updatedAt,
    required this.assignUser,
    required this.assignUsername,
     this.escalationnotify,
     this.escalationnotifyread,
     this.isEsacalted,
     this.isHighlighted,
  });
}
