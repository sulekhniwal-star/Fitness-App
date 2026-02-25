import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../../core/network/pocketbase_client.dart';
import '../../core/storage/hive_service.dart';

class CommunityState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;

  CommunityState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final Ref _ref;

  CommunityNotifier(this._ref) : super(CommunityState()) {
    _loadFromCache();
    fetchPosts();
  }

  void _loadFromCache() {
    final cachedPosts = HiveService.postsBox.values.toList();
    if (cachedPosts.isNotEmpty) {
      state = state.copyWith(posts: cachedPosts);
    }
  }

  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pb = _ref.read(pocketBaseProvider);
      final result = await pb.collection('posts').getList(
            sort: '-created',
            expand: 'user',
          );

      final posts = result.items
          .map((item) => PostModel.fromJson(item.toJson()))
          .toList();

      // Update cache
      await HiveService.postsBox.clear();
      await HiveService.postsBox.addAll(posts);

      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createPost(String content, {String? imagePath}) async {
    try {
      final pb = _ref.read(pocketBaseProvider);
      final user = pb.authStore.record;
      if (user == null) throw Exception('User not authenticated');

      final body = {
        'user': user.id,
        'content': content,
        'likes': [],
      };

      // Mock image upload if path provided (in real app would use MultipartFile)
      // For now, focusing on text posts
      await pb.collection('posts').create(body: body);

      // Refresh feed
      await fetchPosts();
    } catch (e) {
      state = state.copyWith(error: 'Failed to create post: $e');
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      final pb = _ref.read(pocketBaseProvider);
      final userId = pb.authStore.record?.id;
      if (userId == null) return;

      final post = state.posts.firstWhere((p) => p.id == postId);
      final likes = List<String>.from(post.likes);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await pb.collection('posts').update(postId, body: {'likes': likes});

      // Optimistic UI update
      state = state.copyWith(
        posts: state.posts
            .map((p) => p.id == postId ? p.copyWith(likes: likes) : p)
            .toList(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error tipping post: $e');
    }
  }
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref);
});
