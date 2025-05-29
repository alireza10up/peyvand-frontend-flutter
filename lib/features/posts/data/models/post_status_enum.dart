enum PostStatus {
  draft,
  published,
  archived;

  static PostStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'published':
        return PostStatus.published;
      case 'archived':
        return PostStatus.archived;
      case 'draft':
      default:
        return PostStatus.draft;
    }
  }

  @override
  String toString() {
    switch (this) {
      case PostStatus.published:
        return 'published';
      case PostStatus.archived:
        return 'archived';
      case PostStatus.draft:
      default:
        return 'draft';
    }
  }
}