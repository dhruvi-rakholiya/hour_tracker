/// Formats an integer amount of minutes into a human-readable string.
/// Examples (short = true):
///   0 -> "0m"
///   1 -> "1m"
///   30 -> "30m"
///   60 -> "1h"
///   90 -> "1h 30m"
///   150 -> "2h 30m"
///
/// Examples (short = false):
///   0 -> "0 mins"
///   1 -> "1 min"
///   30 -> "30 mins"
///   60 -> "1 hr"
///   90 -> "1 hr 30 mins"
///   150 -> "2 hrs 30 mins"
String formatMinutesToDuration(int totalMinutes, {bool short = true}) {
  if (totalMinutes <= 0) return short ? "0m" : "0 mins";
  final hours = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;

  if (hours == 0) {
    return short ? "${mins}m" : "$mins ${mins == 1 ? 'min' : 'mins'}";
  } else if (mins == 0) {
    return short ? "${hours}h" : "$hours ${hours == 1 ? 'hr' : 'hrs'}";
  } else {
    return short
        ? "${hours}h ${mins}m"
        : "$hours ${hours == 1 ? 'hr' : 'hrs'} $mins ${mins == 1 ? 'min' : 'mins'}";
  }
}

/// Converts fractional hours to total minutes and formats as duration.
/// Examples (short = true):
///   0.5 -> "30m"
///   1.5 -> "1h 30m"
///   2.0 -> "2h"
String formatHoursToDuration(double hours, {bool short = true}) {
  final totalMinutes = (hours * 60).round();
  return formatMinutesToDuration(totalMinutes, short: short);
}
