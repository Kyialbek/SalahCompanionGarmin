using Toybox.Time;
using Toybox.Time.Gregorian;

module HijriService {
    const MONTHS = [
        "Muharram",
        "Safar",
        "Rabi al-Awwal",
        "Rabi al-Thani",
        "Jumada al-Awwal",
        "Jumada al-Thani",
        "Rajab",
        "Sha'ban",
        "Ramadan",
        "Shawwal",
        "Dhu al-Qidah",
        "Dhu al-Hijjah"
    ];

    const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    function today() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var jd = julianDay(info.year, info.month, info.day);
        var islamic = islamicFromJulian(jd);
        return {
            "day" => islamic[2],
            "month" => MONTHS[islamic[1] - 1],
            "year" => islamic[0],
            "weekday" => WEEKDAYS[weekdayIndex(jd)]
        };
    }

    function label() {
        var h = today();
        return h["weekday"] + " " + h["day"] + " " + h["month"];
    }

    function julianDay(year, month, day) {
        var a = (14 - month) / 12;
        var y = year + 4800 - a;
        var m = month + (12 * a) - 3;
        return day + (((153 * m) + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
    }

    function islamicFromJulian(jd) {
        var l = jd - 1948440 + 10632;
        var n = ((l - 1) / 10631);
        l = l - (10631 * n) + 354;
        var j = (((10985 - l) / 5316) * ((50 * l) / 17719)) + ((l / 5670) * ((43 * l) / 15238));
        l = l - (((30 - j) / 15) * ((17719 * j) / 50)) - ((j / 16) * ((15238 * j) / 43)) + 29;
        var month = (24 * l) / 709;
        var day = l - ((709 * month) / 24);
        var year = (30 * n) + j - 30;
        return [year, month, day];
    }

    function weekdayIndex(jd) {
        return (jd + 1) % 7;
    }
}
