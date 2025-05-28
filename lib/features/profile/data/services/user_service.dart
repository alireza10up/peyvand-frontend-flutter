import 'dart:convert';
import 'dart:io';
import 'package:peyvand/features/profile/domain/models/user_model.dart';
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

      return User(
        id: data['id'].toString(),
        email: data['email'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        displayName: data['firstName'] != null ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim() : data['email'],
        bio: data['bio'],
        profileFileId: profileId,
        profilePictureRelativeUrl: profileRelativeUrl,
        university: data['university'],
        skills: data['skills'] != null ? List<String>.from(data['skills']) : null,
        birthDate: data['birthDate'],
        studentCode: data['studentCode'],
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      print('UserService.fetchUserProfile caught generic error: $e. Returning mock data.');
      await Future.delayed(const Duration(seconds: 1));
      return User(
          id: 'user-123',
          email: 'catch_user@example.com',
          firstName: 'کچ',
          lastName: 'کاربر (خطا)',
          displayName: 'کچ کاربر (خطا)',
          bio: 'خطا در دریافت اطلاعات از سرور.',
          profilePictureRelativeUrl: null,
          university: 'دانشگاه خطا',
          skills: ['خطا'],
          studentCode: '000',
          birthDate: null
      );
    }
  }

  Future<Map<String, dynamic>> uploadProfileImageAndGetData(File imageFile, String mimeType) async {
    try {
      final response = await _apiService.uploadFile(
        '/files/public/upload',
        imageFile,
        fieldName: 'file',
        mimeType: mimeType,
      );
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('خطای ناشناخته در آپلود تصویر در UserService: $e');
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
      // TODO ok this
      // 'bio': bio,
      // 'university': university,
      // 'skills': skills,
      'birthDate': birthDate,
      'studentCode': studentCode,
    };

    if (removeProfileFile) {
      body['profileFile'] = null;
    } else if (profileFileId != null) {
      body['profileFile'] = profileFileId;
    }

    try {
      await _apiService.patch('/users/profile', body);
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('خطای ناشناخته در به‌روزرسانی پروفایل: $e');
    }
  }
}