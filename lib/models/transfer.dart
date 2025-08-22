class Transfer {
  final String id;
  final String title;
  final int received;
  final int total;
  final bool error;
  final bool upload;

  Transfer({
    required this.id,
    required this.title,
    required this.received,
    required this.total,
    this.error = false,
    required this.upload
  });
}