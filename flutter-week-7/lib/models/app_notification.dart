class AppNotification {
  final String id;
  final String title;
  final String body;
  final int createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory AppNotification.fromMap(String id, Map map) => AppNotification(
        id: id,
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
        createdAt: map['createdAt'] as int? ?? 0,
      );
}
