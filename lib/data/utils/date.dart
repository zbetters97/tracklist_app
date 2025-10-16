import 'package:intl/intl.dart';

String formatDateMDYLong(DateTime date) {
  final formattedDate = DateFormat("MMM d, y", "en_US").format(date);
  return formattedDate;
}

String getTimeSinceShort(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}hr ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).round()}w ago';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).round()}mo ago';
  } else {
    return '${(difference.inDays / 365).round()}y ago';
  }
}
