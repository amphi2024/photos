abstract final class SortOption {
  static const created = "created";
  static const createdDescending = "created,descending";
  static const modified = "modified";
  static const modifiedDescending = "modified,descending";
  static const date = "date";
  static const dateDescending = "date,descending";
  static const deleted = "deleted";
  static const deletedDescending = "deleted,descending";
  static const title = "title";
  static const titleDescending = "title,descending";
}

extension DescendingEx on String {
  bool isDescending() => endsWith(",descending");
}