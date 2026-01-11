import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AdminService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getPatients({String? search, int page = 1}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.apiUrl}/admin/patients?page=$page${search != null ? '&search=$search' : ''}');
      
      print('AdminService.getPatients - URL: $url');
      print('AdminService.getPatients - Headers: $headers');
      
      final response = await http.get(url, headers: headers);
      
      print('AdminService.getPatients - Status: ${response.statusCode}');
      print('AdminService.getPatients - Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load patients: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('AdminService.getPatients - Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getQueueSettings() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.apiUrl}/admin/queue-settings');
      
      print('AdminService.getQueueSettings - URL: $url');
      print('AdminService.getQueueSettings - Headers: $headers');
      
      final response = await http.get(url, headers: headers);
      
      print('AdminService.getQueueSettings - Status: ${response.statusCode}');
      print('AdminService.getQueueSettings - Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      throw Exception('Failed to load settings: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('AdminService.getQueueSettings - Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateQueueSetting(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${AppConfig.apiUrl}/admin/queue-settings/$id'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update setting');
  }

  static Future<Map<String, dynamic>> bulkCancelQueues(List<int> queueIds, String reason) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/admin/queues/bulk-cancel'),
      headers: headers,
      body: json.encode({
        'queue_ids': queueIds,
        'reason': reason,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to cancel queues');
  }

  static Future<Map<String, dynamic>> resetAllQueues(String date, {int? departmentId}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/admin/queues/reset-all'),
      headers: headers,
      body: json.encode({
        'date': date,
        'department_id': departmentId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to reset queues');
  }

  static Future<Map<String, dynamic>> getAuditLogs({
    String? action,
    int? userId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${AppConfig.apiUrl}/admin/audit-logs?page=$page';
      if (action != null) url += '&action=$action';
      if (userId != null) url += '&user_id=$userId';
      if (dateFrom != null) url += '&date_from=$dateFrom';
      if (dateTo != null) url += '&date_to=$dateTo';

      print('AdminService.getAuditLogs - URL: $url');
      print('AdminService.getAuditLogs - Headers: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('AdminService.getAuditLogs - Status: ${response.statusCode}');
      print('AdminService.getAuditLogs - Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load audit logs: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('AdminService.getAuditLogs - Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getReportData(String dateFrom, String dateTo, {int? departmentId}) async {
    final headers = await _getHeaders();
    var url = '${AppConfig.apiUrl}/admin/reports/queue-data?date_from=$dateFrom&date_to=$dateTo';
    if (departmentId != null) url += '&department_id=$departmentId';

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load report data');
  }
}
