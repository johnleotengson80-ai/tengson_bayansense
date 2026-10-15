const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Oct 8, 2026". Date only on purpose: the server stores timestamps without a time zone,
/// so showing a clock time could be wrong for the resident.
String formatDate(DateTime date) => '${_months[date.month - 1]} ${date.day}, ${date.year}';
