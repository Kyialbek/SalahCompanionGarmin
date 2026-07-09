using Toybox.Time;
using Toybox.Time.Gregorian;

module SalahTimeUtils {
    const MONTH_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    function nowInfo() {
        return Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    }

    function todaySerial() {
        var info = nowInfo();
        return dateSerial(info.year, info.month, info.day);
    }

    function currentMinutes() {
        var info = nowInfo();
        return info.hour * 60 + info.min;
    }

    function dateSerial(year, month, day) {
        var days = 0;
        for (var y = 2024; y < year; y += 1) {
            days += isLeap(y) ? 366 : 365;
        }

        for (var m = 1; m < month; m += 1) {
            days += daysInMonth(year, m);
        }

        return days + day;
    }

    function daysInMonth(year, month) {
        if (month == 2 && isLeap(year)) {
            return 29;
        }

        return MONTH_DAYS[month - 1];
    }

    function isLeap(year) {
        if (year % 400 == 0) {
            return true;
        }

        if (year % 100 == 0) {
            return false;
        }

        return year % 4 == 0;
    }

    function formatMinutes(minutes) {
        var hour = minutes / 60;
        var min = minutes % 60;
        var suffix = "AM";

        if (hour >= 12) {
            suffix = "PM";
        }

        var displayHour = hour % 12;
        if (displayHour == 0) {
            displayHour = 12;
        }

        return displayHour + ":" + twoDigits(min) + " " + suffix;
    }

    function durationText(totalMinutes) {
        if (totalMinutes < 0) {
            totalMinutes = 0;
        }

        var hours = totalMinutes / 60;
        var mins = totalMinutes % 60;
        if (hours <= 0) {
            return mins + "m";
        }

        return hours + "h " + mins + "m";
    }

    function twoDigits(value) {
        return value < 10 ? "0" + value : "" + value;
    }
}
