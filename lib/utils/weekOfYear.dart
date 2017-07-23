/*
Implementation blatantly stolen from OriginalGriff
https://www.codeproject.com/Tips/226252/DateTime-Extension-Method-to-Give-Week-Number
 */

List<int> moveByDays = [0, 7, 8, 9, 10, 4, 5, 6];

weekOfYear(DateTime date) {
  DateTime startOfYear = new DateTime(date.year, 1, 1);
  DateTime endOfYear = new DateTime(date.year, 12, 31);

  int numberDays =
      date.difference(startOfYear).inDays + moveByDays[startOfYear.weekday];
  int weekNumber = numberDays ~/ 7;

  switch (weekNumber) {
    case 0:
      weekNumber = weekOfYear(startOfYear.subtract(new Duration(days: 1)));
      break;
    case 53:
      if (endOfYear.weekday < DateTime.THURSDAY) {
        weekNumber = 1;
      }
      break;
  }
  return weekNumber;
}
