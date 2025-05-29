import 'dart:io';

import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/errors/api_exception.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/models/post_status_enum.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';

class PostService {
  final ApiService _apiService = ApiService();
  final UserService _userService = UserService();

  Future<Post> createPost({
    String? title,
    required String content,
    List<File> images = const [],
    List<String> imageMimeTypes = const [],
  }) async {
    try {
      List<int> fileIds = [];
      if (images.isNotEmpty && images.length == imageMimeTypes.length) {
        for (int i = 0; i < images.length; i++) {
          final uploadedFile = await _apiService.uploadFile(
            '/files/public/upload',
            images[i],
            fieldName: 'file',
            mimeType: imageMimeTypes[i],
          );
          if (uploadedFile['success'] == true && uploadedFile['id'] != null) {
            fileIds.add(uploadedFile['id']);
          } else {
            throw ApiException(messages: ['خطا در آپلود یکی از تصاویر.']);
          }
        }
      }

      final Map<String, dynamic> postData = {'content': content};
      if (title != null && title.isNotEmpty) {
        postData['title'] = title;
      }
      if (fileIds.isNotEmpty) {
        postData['file_ids'] = fileIds;
      }

      final response = await _apiService.post('/posts', postData);
      return Post.fromJson(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(messages: ['خطا در ایجاد پست: ${e.toString()}']);
    }
  }

  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final response = await _apiService.get('/posts/user/$userId');
      if (response is List) {
        return response.map((postJson) => Post.fromJson(postJson)).toList();
      } else {
        throw ApiException(
          messages: ['فرمت پاسخ دریافت لیست پست‌ها نامعتبر است.'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        messages: ['خطا در دریافت پست‌های کاربر: ${e.toString()}'],
      );
    }
  }

  Future<Post> updatePost({
    required int postId,
    String? title,
    String? content,
    PostStatus? status,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;
      if (status != null) updateData['status'] = status.toString();

      if (updateData.isEmpty && status == null) {
        throw ApiException(messages: ['هیچ تغییری برای ذخیره وجود ندارد.']);
      }

      final response = await _apiService.patch('/posts/$postId', updateData);
      return Post.fromJson(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(messages: ['خطا در به‌روزرسانی پست: ${e.toString()}']);
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _apiService.delete('/posts/$postId');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(messages: ['خطا در حذف پست: ${e.toString()}']);
    }
  }
}
