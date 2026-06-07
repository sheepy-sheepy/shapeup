class ProgressPhotoEntity {
  const ProgressPhotoEntity({
    required this.id,
    required this.userId,
    required this.dayKey,
    required this.slot,
    required this.localPath,
  });

  final String id;
  final String userId;
  final String dayKey;
  final int slot;
  final String localPath;
}
