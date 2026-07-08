using Toybox.Time;
using Toybox.Time.Gregorian;

module SalahTimes {
    const PRAYERS = [
        { "key" => "fajr", "name" => "Fajr" },
        { "key" => "dhuhr", "name" => "Dhuhr" },
        { "key" => "asr", "name" => "Asr" },
        { "key" => "maghrib", "name" => "Maghrib" },
        { "key" => "isha", "name" => "Isha" }
    ];

    // Naperville, IL approximate monthly Hanafi-friendly defaults.
    // The phone/web app keeps the exact richer calculation; this watch app is a fast standalone companion.
    const MONTH_TIMES = [
        [365, 750, 895, 1000, 1090],
        [335, 750, 920, 1035, 1120],
        [320, 770, 965, 1100, 1185],
        [285, 775, 1010, 1165, 1260],
        [240, 775, 1050, 1220, 1325],
        [215, 780, 1090, 1250, 1365],
        [220, 785, 1095, 1250, 1360],
        [250, 780, 1065, 1210, 1305],
        [290, 765, 1010, 1145, 1225],
        [330, 750, 945, 1075, 1150],
        [365, 740, 895, 1015, 1095],
        [390, 740, 875, 990, 1070]
    ];

    function currentMinutes() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        return info.hour * 60 + info.min;
    }

    function monthIndex() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return info.month - 1;
    }

    function nextPrayer() {
        var minutes = currentMinutes();
        var times = MONTH_TIMES[monthIndex()];

        for (var i = 0; i < PRAYERS.size(); i += 1) {
            if (minutes < times[i]) {
                return prayerResult(i, times[i], false);
            }
        }

        return prayerResult(0, MONTH_TIMES[monthIndex()][0], true);
    }

    function prayerResult(index, minutes, tomorrow) {
        var prayer = PRAYERS[index];
        return {
            "key" => prayer["key"],
            "name" => prayer["name"],
            "context" => tomorrow ? "Tomorrow" : "Next prayer",
            "day" => tomorrow ? "Tomorrow" : "Today",
            "time" => formatMinutes(minutes),
            "remaining" => remainingText(minutes, tomorrow)
        };
    }

    function remainingText(targetMinutes, tomorrow) {
        var nowMinutes = currentMinutes();
        var delta = targetMinutes - nowMinutes;
        if (tomorrow) {
            delta += 1440;
        }

        var hours = delta / 60;
        var mins = delta % 60;
        if (hours <= 0) {
            return mins + "m";
        }

        return hours + "h " + mins + "m";
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

        var minText = min < 10 ? "0" + min : "" + min;
        return displayHour + ":" + minText + " " + suffix;
    }
}
