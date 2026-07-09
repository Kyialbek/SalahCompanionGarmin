using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian;

module CalculationService {
    const FALLBACK_LAT = 41.7508;
    const FALLBACK_LON = -88.1535;
    const FALLBACK_LOCATION = "Naperville, IL";

    const METHODS = [
        { "key" => "MWL", "name" => "MWL", "fajr" => 18.0, "isha" => 17.0, "ishaMinutes" => 0 },
        { "key" => "ISNA", "name" => "ISNA", "fajr" => 15.0, "isha" => 15.0, "ishaMinutes" => 0 },
        { "key" => "Egypt", "name" => "Egypt", "fajr" => 19.5, "isha" => 17.5, "ishaMinutes" => 0 },
        { "key" => "UQ", "name" => "Umm Al-Qura", "fajr" => 18.5, "isha" => 0.0, "ishaMinutes" => 90 },
        { "key" => "Karachi", "name" => "Karachi", "fajr" => 18.0, "isha" => 18.0, "ishaMinutes" => 0 },
        { "key" => "Custom", "name" => "Custom", "fajr" => 18.0, "isha" => 17.0, "ishaMinutes" => 0 }
    ];

    const PRAYERS = [
        { "key" => "fajr", "name" => "Fajr" },
        { "key" => "sunrise", "name" => "Sunrise" },
        { "key" => "dhuhr", "name" => "Dhuhr" },
        { "key" => "asr", "name" => "Asr" },
        { "key" => "maghrib", "name" => "Maghrib" },
        { "key" => "isha", "name" => "Isha" }
    ];

    function settings() {
        var methodIndex = StorageService.readNumber(StorageService.METHOD_KEY, 1);
        if (methodIndex < 0 || methodIndex >= METHODS.size()) {
            methodIndex = 1;
        }

        return {
            "methodIndex" => methodIndex,
            "method" => METHODS[methodIndex],
            "asrHanafi" => StorageService.readNumber(StorageService.ASR_KEY, 1) == 1,
            "lat" => StorageService.readFloat(StorageService.LOCATION_LAT_KEY, FALLBACK_LAT),
            "lon" => StorageService.readFloat(StorageService.LOCATION_LON_KEY, FALLBACK_LON),
            "customFajr" => StorageService.readFloat(StorageService.CUSTOM_FAJR_KEY, 18.0),
            "customIsha" => StorageService.readFloat(StorageService.CUSTOM_ISHA_KEY, 17.0)
        };
    }

    function cycleMethod() {
        var index = StorageService.readNumber(StorageService.METHOD_KEY, 1) + 1;
        if (index >= METHODS.size()) {
            index = 0;
        }
        StorageService.setValue(StorageService.METHOD_KEY, index);
    }

    function toggleAsr() {
        StorageService.setValue(StorageService.ASR_KEY, StorageService.readNumber(StorageService.ASR_KEY, 1) == 1 ? 0 : 1);
    }

    function todaySchedule() {
        return scheduleForOffset(0);
    }

    function scheduleForOffset(dayOffset) {
        var now = Time.now().add(new Time.Duration(dayOffset * 86400));
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        var year = safeNumber(date.year, 2026);
        var month = safeNumber(date.month, 1);
        var day = safeNumber(date.day, 1);
        var s = settings();
        var method = s["method"];
        var fajrAngle = method["key"] == "Custom" ? s["customFajr"] : method["fajr"];
        var ishaAngle = method["key"] == "Custom" ? s["customIsha"] : method["isha"];
        var noon = solarNoonMinutes(date, s["lon"]);
        var decl = sunDeclination(dayOfYear(year, month, day));
        var lat = s["lat"];
        var sunrise = noon - hourAngleMinutes(lat, decl, -0.833);
        var sunset = noon + hourAngleMinutes(lat, decl, -0.833);
        var fajr = noon - hourAngleMinutes(lat, decl, 0 - fajrAngle);
        var isha = method["ishaMinutes"] > 0 ? sunset + method["ishaMinutes"] : noon + hourAngleMinutes(lat, decl, 0 - ishaAngle);
        var asrFactor = s["asrHanafi"] ? 2.0 : 1.0;
        var asrAngle = -radToDeg(Math.atan(1.0 / (asrFactor + Math.tan(absDeg(lat - decl) * Math.PI / 180.0))));
        var asr = noon + hourAngleMinutes(lat, decl, asrAngle);

        return [
            prayerResult(0, roundMinute(fajr), false),
            prayerResult(1, roundMinute(sunrise), false),
            prayerResult(2, roundMinute(noon + 2), false),
            prayerResult(3, roundMinute(asr), false),
            prayerResult(4, roundMinute(sunset), false),
            prayerResult(5, roundMinute(isha), false)
        ];
    }

    function nextPrayer() {
        var minutes = currentMinutes();
        var schedule = todaySchedule();

        for (var i = 0; i < schedule.size(); i += 1) {
            if (minutes < schedule[i]["minutes"]) {
                schedule[i]["remaining"] = remainingText(schedule[i]["minutes"], false);
                schedule[i]["progress"] = progressTo(schedule, i, schedule[i]["minutes"], false);
                return schedule[i];
            }
        }

        var tomorrow = scheduleForOffset(1)[0];
        tomorrow["day"] = "Tomorrow";
        tomorrow["remaining"] = remainingText(tomorrow["minutes"], true);
        tomorrow["progress"] = progressTo(schedule, 0, tomorrow["minutes"], true);
        return tomorrow;
    }

    function currentPrayerKey() {
        var minutes = currentMinutes();
        var schedule = todaySchedule();
        var current = schedule[0]["key"];
        for (var i = 0; i < schedule.size(); i += 1) {
            if (minutes >= schedule[i]["minutes"]) {
                current = schedule[i]["key"];
            }
        }
        return current;
    }

    function currentMinutes() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        return (safeNumber(info.hour, 0) * 60) + safeNumber(info.min, 0);
    }

    function prayerResult(index, minutes, tomorrow) {
        var prayer = PRAYERS[index];
        return {
            "key" => prayer["key"],
            "name" => prayer["name"],
            "day" => tomorrow ? "Tomorrow" : "Today",
            "minutes" => minutes,
            "time" => formatMinutes(minutes),
            "remaining" => remainingText(minutes, tomorrow),
            "progress" => 0
        };
    }

    function progressTo(schedule, index, targetMinutes, tomorrow) {
        var previousIndex = index == 0 ? schedule.size() - 1 : index - 1;
        var previous = schedule[previousIndex]["minutes"];
        var target = targetMinutes;
        var now = currentMinutes();

        if (tomorrow) {
            target += 1440;
        }
        if (previousIndex > index || tomorrow) {
            if (now < previous) {
                now += 1440;
            }
        }

        var span = target - previous;
        if (span <= 0) {
            return 0;
        }

        var value = ((now - previous) * 100) / span;
        if (value < 0) {
            return 0;
        }
        if (value > 100) {
            return 100;
        }
        return value;
    }

    function solarNoonMinutes(date, lon) {
        var n = dayOfYear(date.year, date.month, date.day);
        var eq = equationOfTime(n);
        var tz = localUtcOffsetHours();
        return 720.0 - (4.0 * lon) - eq + (60.0 * tz);
    }

    function localUtcOffsetHours() {
        var local = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var utc = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
        if (local == null || utc == null || local.hour == null || utc.hour == null || local.min == null || utc.min == null) {
            return -5.0;
        }

        var localMinutes = local.hour * 60 + local.min;
        var utcMinutes = utc.hour * 60 + utc.min;
        var diff = localMinutes - utcMinutes;
        var localDay = safeNumber(local.day, 1);
        var localMonth = safeNumber(local.month, 1);
        var localYear = safeNumber(local.year, 2026);
        var utcDay = safeNumber(utc.day, 1);
        var utcMonth = safeNumber(utc.month, 1);
        var utcYear = safeNumber(utc.year, 2026);

        if (localYear > utcYear || localMonth > utcMonth || localDay > utcDay) {
            diff += 1440;
        } else if (localYear < utcYear || localMonth < utcMonth || localDay < utcDay) {
            diff -= 1440;
        }
        return diff / 60.0;
    }

    function safeNumber(value, fallback) {
        if (value == null) {
            return fallback;
        }

        var number = ("" + value).toNumber();
        return number == null ? fallback : number;
    }

    function equationOfTime(n) {
        var b = degToRad((360.0 / 365.0) * (n - 81));
        return (9.87 * Math.sin(2 * b)) - (7.53 * Math.cos(b)) - (1.5 * Math.sin(b));
    }

    function sunDeclination(n) {
        return 23.45 * Math.sin(degToRad((360.0 / 365.0) * (284 + n)));
    }

    function hourAngleMinutes(lat, decl, altitude) {
        var latRad = degToRad(lat);
        var declRad = degToRad(decl);
        var altRad = degToRad(altitude);
        var value = (Math.sin(altRad) - (Math.sin(latRad) * Math.sin(declRad))) / (Math.cos(latRad) * Math.cos(declRad));
        if (value < -1.0) {
            value = -1.0;
        }
        if (value > 1.0) {
            value = 1.0;
        }
        return radToDeg(Math.acos(value)) * 4.0;
    }

    function dayOfYear(year, month, day) {
        var monthDays = [31, isLeap(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        var total = day;
        for (var i = 0; i < month - 1; i += 1) {
            total += monthDays[i];
        }
        return total;
    }

    function isLeap(year) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    }

    function formatMinutes(minutes) {
        while (minutes < 0) {
            minutes += 1440;
        }
        while (minutes >= 1440) {
            minutes -= 1440;
        }
        var hour = minutes / 60;
        var min = minutes % 60;
        var suffix = hour >= 12 ? "PM" : "AM";
        var displayHour = hour % 12;
        if (displayHour == 0) {
            displayHour = 12;
        }
        var minText = min < 10 ? "0" + min : "" + min;
        return displayHour + ":" + minText + " " + suffix;
    }

    function remainingText(targetMinutes, tomorrow) {
        var delta = targetMinutes - currentMinutes();
        if (tomorrow) {
            delta += 1440;
        }
        if (delta < 0) {
            delta = 0;
        }
        var hours = delta / 60;
        var mins = delta % 60;
        return hours <= 0 ? mins + "m" : hours + "h " + mins + "m";
    }

    function roundMinute(value) {
        return (value + 0.5).toNumber();
    }

    function degToRad(value) {
        return value * Math.PI / 180.0;
    }

    function radToDeg(value) {
        return value * 180.0 / Math.PI;
    }

    function absDeg(value) {
        return value < 0 ? 0 - value : value;
    }
}
