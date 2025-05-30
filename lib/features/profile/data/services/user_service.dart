import 'dart:io';
import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/errors/api_exception.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<User> fetchUserProfile() async {
    try {
      final data = await _apiService.get('/users/profile');

      String? profileRelativeUrl;
      int? profileId;

      if (data['profileFile'] != null && data['profileFile'] is Map) {
        profileRelativeUrl = data['profileFile']['url'];
        profileId = data['profileFile']['id'];
      } else if (data['profileFile'] != null && data['profileFile'] is int) {
        profileId = data['profileFile'];
      }

      DateTime? createdAtDate;
      if (data['createdAt'] != null) {
        createdAtDate = DateTime.tryParse(data['createdAt']);
      }

      return User(
        id: data['id'].toString(),
        email: data['email'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        displayName:
        data['firstName'] != null
            ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim()
            : data['email'],
        bio: data['bio'],
        profileFileId: profileId,
        profilePictureRelativeUrl: profileRelativeUrl,
        university: data['university'],
        skills:
        data['skills'] != null ? List<String>.from(data['skills']) : null,
        birthDate: data['birthDate'],
        studentCode: data['studentCode'],
        createdAtDate: createdAtDate,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(messages: ['خطا در دریافت پروفایل کاربر لاگین شده.']);
    }
  }

  Future<User> fetchUserProfileById(String userId) async {
    try {
      final data = await _apiService.get('/users/$userId/profile');

      String? profileRelativeUrl;
      int? profileId;

      if (data['profileFile'] != null && data['profileFile'] is Map) {
        profileRelativeUrl = data['profileFile']['url'];
        profileId = data['profileFile']['id'];
      } else if (data['profileFile'] != null && data['profileFile'] is int) {
        profileId = data['profileFile'];
      }

      DateTime? createdAtDate;
      if (data['createdAt'] != null) {
        createdAtDate = DateTime.tryParse(data['createdAt']);
      }
      // String? birthDateString;
      // if (data['birthDate'] != null) {
      //   birthDateString = data['birthDate']; // Assuming it's a string like "YYYY-MM-DD"
      // }


      return User(
        id: data['id'].toString(),
        email: data['email'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        displayName:
        (data['firstName'] != null || data['lastName'] != null)
            ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim()
            : data['email'],
        bio: data['bio'],
        profileFileId: profileId,
        profilePictureRelativeUrl: profileRelativeUrl,
        university: data['university'],
        skills:
        data['skills'] != null ? List<String>.from(data['skills']) : null,
        birthDate: data['birthDate'],
        studentCode: data['studentCode'],
        createdAtDate: createdAtDate,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(messages: ['خطا در دریافت پروفایل کاربر با شناسه $userId.']);
    }
  }

  Future<Map<String, dynamic>> uploadProfileImageAndGetData(
      File imageFile,
      String mimeType,
      ) async {
    try {
      final response = await _apiService.uploadFile(
        '/files/public/upload',
        imageFile,
        fieldName: 'file',
        mimeType: mimeType,
      );
      return response;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(messages: [e.toString()]);
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? bio,
    int? profileFileId,
    String? university,
    List<String>? skills,
    String? birthDate,
    String? studentCode,
    bool removeProfileFile = false,
  }) async {
    Map<String, dynamic> body = {
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'university': university,
      'skills': skills,
      'birthDate': birthDate,
      'studentCode': studentCode,
    };

    if (removeProfileFile) {
      body['profileFile'] = null;
    } else if (profileFileId != null) {
      body['profileFile'] = profileFileId;
    }

    body.removeWhere((key, value) => value == null && key != 'profileFile');
    try {
      await _apiService.patch('/users/profile', body);
      return true;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(messages: [e.toString()]);
    }
  }
}