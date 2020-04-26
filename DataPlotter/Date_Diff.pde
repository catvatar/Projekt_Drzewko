//http://www.sunshine2k.de/articles/coding/datediffindays/calcdiffofdatesindates.html
//funkcje zaadaptowane z poradnika do którego link znajduje się powyżej


int[] daysUpToMonth = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };
int[] daysUpToMonthLeapYear = { 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 };

public static boolean IsLeapYear(int y){
  return (y%4 == 0 ? (y%100 == 0 ? (y%400 == 0 ? true : false) : true) : false);
}

public static boolean IsDate1BeforeThanDate2(int y1, int m1, int d1, int y2, int m2, int d2)
{
  return (y1 < y2 ? true : (y1 == y2 ? (m1 < m2 ? true : (m1 == m2 ? (d1 < d2 ? true : false) : false)):false));
}
public int GetRemainingDaysInYear(int month, int day, boolean isLeapYear){
  if (isLeapYear){
    return 366 - (daysUpToMonthLeapYear[month - 1] + day);
  }else{
    return 365 - (daysUpToMonth[month - 1] + day);
  }
}

public int GetDaysInYearTillDate(int month, int day, boolean isLeapYear){
  if (isLeapYear){
    return daysUpToMonthLeapYear[month - 1] + day;
  }else{
    return daysUpToMonth[month - 1] + day;
  }
}

public int GetDiffInDaysInSameYear(int month1, int day1, int month2, int day2, boolean isLeapYear){
  if (isLeapYear){
    return daysUpToMonthLeapYear[month2 - 1] - daysUpToMonthLeapYear[month1 - 1] + (day2 - day1);
  }else{
    return daysUpToMonth[month2 - 1] - daysUpToMonth[month1 - 1] + (day2 - day1);
  }
}

public int GetDifference(int yearPreceding,int monthPreceding, int dayPreceding, int yearSubsequent, int monthSubsequent, int daySubsequent){
  if (yearPreceding == yearSubsequent){ /* same year, easy special case */
    return GetDiffInDaysInSameYear(monthPreceding, dayPreceding, monthSubsequent, daySubsequent, IsLeapYear(yearPreceding));
  }else{
    int resultDays = 0;
    /* Step 1: handle first (incomplete) year */
    resultDays = GetRemainingDaysInYear(monthPreceding, dayPreceding, IsLeapYear(yearPreceding));
    /* first year is now handled */
    yearPreceding++;
    /* Step 2: handle 'full' years */
    while (yearPreceding < yearSubsequent){
      resultDays += IsLeapYear(yearPreceding) ? 366 : 365;
      yearPreceding++;
    }
    /* Step 3: handle last (incomplete) year */
    resultDays += GetDaysInYearTillDate(monthSubsequent, daySubsequent, IsLeapYear(yearSubsequent));
    return resultDays;
  }
}
