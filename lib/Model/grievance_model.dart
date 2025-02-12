
class TicketModel {
  String? grievanceid;
  String? grievanceMode;
  String? complainttypetitle;
  String? deptname;
  String? zone;
  String? ward;
  String? street;
  String? pincode;
  String? complaint;
  String? complaintdetails;
  String? publicuserid;
  String? publicUsername;
  String? phone;
  String? status;
  String? statusflow;
  String? priority;
  String?lat;
  String?lon;
  String? assignuserid;
  String? assingusername;
  String? assingnuserPhone;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? isHighlighted;
  String? isEsacalted;
  String? escalationnotify;
  String? escalationnotifyread;

  TicketModel({

    this.grievanceid,
    this.grievanceMode,
    this.complainttypetitle,
    this.deptname,
    this.zone,
    this.ward,
    this.street,
    this.pincode,
    this.complaint,
    this.complaintdetails,
    this.publicuserid,
    this.publicUsername,
    this.phone,
    this.status,
    this.statusflow,
    this.priority,
    this.lat,
    this.lon,
    this.assignuserid,
    this.assingnuserPhone,
    this.assingusername,
    this.createdAt,
    this.updatedAt,
    this.escalationnotify,
    this.escalationnotifyread,
    this.isEsacalted,
    this.isHighlighted
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
       
        grievanceid: json["grievance_id"],
        grievanceMode: json["grievance_mode"],
        complainttypetitle: json['complaint_type_title'],
        deptname: json['dept_name'],
        zone: json['zone_name'],
        ward: json['ward_name'],
        street: json['street_name'],
        pincode: json["pincode"], 
        complaint: json['complaint'],
        complaintdetails: json['complaint_details'],
        publicuserid: json['public_user_id'],
        publicUsername: json['public_user_name'],
        phone: json["phone"],
        status: json["status"],
        statusflow: json["statusflow"], 
        priority: json['priority'],
        lat: json['lat'],
        lon: json['lon'],
        assignuserid: json["assign_user"],
        assingusername: json["assign_username"],
        assingnuserPhone: json["assign_userphone"],
        isEsacalted: json['isEsacalted'],
        isHighlighted: json['isHighlighted'],
        escalationnotify: json['escalation_notify'],
        escalationnotifyread: json['escalation_notify_read'],
        createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
        updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
      );

  Map<String, dynamic> toJson() => {
        
        "grievance_id": grievanceid,
        "grievance_mode": grievanceMode,
        "complaint_type_title":complainttypetitle,
        "dept_name": deptname,
        "zone_name":zone,
        "ward_name":ward,
        "street_name":street,
        "pincode": pincode,
        "complaint": complaint,
        "complaint_details": complaintdetails,
        "public_user_id":publicuserid,
        "public_user_name":publicUsername,
        "phone": phone,
        "status": status,
        "status_flow": statusflow,
        "priority": priority,
        "lat":lat,
        "lon":lon,
        "assign_user": assignuserid,
        "assign_username": assingusername,
        "assign_userphone": assingnuserPhone,
        "escalation_notify_read":escalationnotifyread,
        "escalation_notify": escalationnotify,
        "isHighlighted":isHighlighted,
        "isEsacalted":isEsacalted,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
