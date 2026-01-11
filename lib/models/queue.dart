class Queue {
  final int id;
  final String queueDate;
  final int queueNumber;
  final String status;
  final Department? department;
  final Doctor? doctor;
  final int? estimatedWaitMinutes;
  final String? cancelReason;
  final QueueNote? note;

  Queue({
    required this.id,
    required this.queueDate,
    required this.queueNumber,
    required this.status,
    this.department,
    this.doctor,
    this.estimatedWaitMinutes,
    this.cancelReason,
    this.note,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    return Queue(
      id: json['id'],
      queueDate: json['queue_date'],
      queueNumber: json['queue_number'],
      status: json['status'],
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
      estimatedWaitMinutes: json['estimated_wait_minutes'],
      cancelReason: json['cancel_reason'],
      note: json['note'] != null ? QueueNote.fromJson(json['note']) : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'waiting':
        return 'Menunggu';
      case 'called':
        return 'Dipanggil';
      case 'done':
        return 'Selesai';
      case 'skipped':
        return 'Dilewati';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get estimatedWaitText {
    if (estimatedWaitMinutes == null) return '';
    if (estimatedWaitMinutes! < 60) {
      return '~$estimatedWaitMinutes menit';
    }
    final hours = estimatedWaitMinutes! ~/ 60;
    final minutes = estimatedWaitMinutes! % 60;
    return '~$hours jam ${minutes > 0 ? "$minutes menit" : ""}';
  }
}

class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Doctor {
  final int id;
  final String name;

  Doctor({required this.id, required this.name});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
    );
  }
}


class QueueNote {
  final int id;
  final String? diagnosis;
  final String? prescription;
  final String? notes;
  final Doctor? doctor;

  QueueNote({
    required this.id,
    this.diagnosis,
    this.prescription,
    this.notes,
    this.doctor,
  });

  factory QueueNote.fromJson(Map<String, dynamic> json) {
    return QueueNote(
      id: json['id'],
      diagnosis: json['diagnosis'],
      prescription: json['prescription'],
      notes: json['notes'],
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
    );
  }
}
