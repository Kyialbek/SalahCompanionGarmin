using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

module StorageService {
    const VERSION = 2;
    const DAY_KEY = "day_key";
    const COMPLETED_KEY = "completed_prayers";
    const MISSED_KEY = "missed_prayers";
    const CURRENT_STREAK_KEY = "current_streak";
    const LONGEST_STREAK_KEY = "longest_streak";
    const LAST_COMPLETE_DAY_KEY = "last_complete_day";
    const TASBIH_COUNT_KEY = "tasbih_count";
    const TASBIH_TARGET_KEY = "tasbih_target";
    const METHOD_KEY = "calc_method";
    const ASR_KEY = "asr_madhhab";
    const CUSTOM_FAJR_KEY = "custom_fajr";
    const CUSTOM_ISHA_KEY = "custom_isha";
    const REMINDER_KEY = "reminder_offset";
    const LAST_REMINDER_KEY = "last_reminder_key";
    const LOCATION_LAT_KEY = "location_lat";
    const LOCATION_LON_KEY = "location_lon";
    const HISTORY_PREFIX = "hist_";

    function boot() {
        readNumber("storage_version", VERSION);
        Application.Storage.setValue("storage_version", VERSION);
        ensureToday();
    }

    function todayKey() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return (safeNumber(info.year, 2026) * 10000) + (safeNumber(info.month, 1) * 100) + safeNumber(info.day, 1);
    }

    function ensureToday() {
        var today = todayKey();
        var storedDay = readNumber(DAY_KEY, today);
        if (storedDay != today) {
            finalizeStoredDay(storedDay);
            Application.Storage.setValue(DAY_KEY, today);
            Application.Storage.setValue(COMPLETED_KEY, "");
            Application.Storage.setValue(MISSED_KEY, "");
            Application.Storage.setValue(LAST_REMINDER_KEY, "");
        } else {
            writeTodayHistory();
        }
    }

    function finalizeStoredDay(storedDay) {
        if (storedDay == null || storedDay <= 0) {
            return;
        }

        var completed = readString(COMPLETED_KEY, "");
        var completeCount = completedPrayerCount(completed);
        var missed = 5 - completeCount;
        Application.Storage.setValue(historyKey(storedDay), prayerMask(completed));

        if (missed <= 0) {
            var current = readNumber(CURRENT_STREAK_KEY, 0) + 1;
            Application.Storage.setValue(CURRENT_STREAK_KEY, current);
            if (current > readNumber(LONGEST_STREAK_KEY, 0)) {
                Application.Storage.setValue(LONGEST_STREAK_KEY, current);
            }
            Application.Storage.setValue(LAST_COMPLETE_DAY_KEY, storedDay);
        } else {
            Application.Storage.setValue(CURRENT_STREAK_KEY, 0);
        }
    }

    function readString(key, fallback) {
        try {
            var value = Application.Storage.getValue(key);
            if (value == null) {
                Application.Storage.setValue(key, fallback);
                return fallback;
            }
            return "" + value;
        } catch (ex) {
            Application.Storage.setValue(key, fallback);
            return fallback;
        }
    }

    function readNumber(key, fallback) {
        try {
            var value = Application.Storage.getValue(key);
            if (value == null) {
                Application.Storage.setValue(key, fallback);
                return fallback;
            }
            if (value < -1000000 || value > 100000000) {
                Application.Storage.setValue(key, fallback);
                return fallback;
            }
            return value;
        } catch (ex) {
            Application.Storage.setValue(key, fallback);
            return fallback;
        }
    }

    function readFloat(key, fallback) {
        try {
            var value = Application.Storage.getValue(key);
            if (value == null) {
                Application.Storage.setValue(key, fallback);
                return fallback;
            }
            if (value < -1000000.0 || value > 1000000.0) {
                Application.Storage.setValue(key, fallback);
                return fallback;
            }
            return value;
        } catch (ex) {
            Application.Storage.setValue(key, fallback);
            return fallback;
        }
    }

    function tokenCount(value) {
        var count = 0;
        var inToken = false;
        for (var i = 0; i < value.length(); i += 1) {
            var ch = value.substring(i, i + 1);
            if (ch == ",") {
                if (inToken) {
                    count += 1;
                }
                inToken = false;
            } else if (ch != "") {
                inToken = true;
            }
        }
        if (inToken) {
            count += 1;
        }
        return count;
    }

    function hasToken(value, token) {
        return ("," + value + ",").find("," + token + ",") != null;
    }

    function addToken(key, token) {
        ensureToday();
        var value = readString(key, "");
        if (hasToken(value, token)) {
            return value;
        }
        value = value == "" ? token : value + "," + token;
        Application.Storage.setValue(key, value);
        if (key == COMPLETED_KEY) {
            writeTodayHistory();
        }
        return value;
    }

    function removeToken(key, token) {
        ensureToday();
        var value = readString(key, "");
        var next = "";
        var current = "";
        for (var i = 0; i < value.length(); i += 1) {
            var ch = value.substring(i, i + 1);
            if (ch == ",") {
                if (current != "" && current != token) {
                    next = next == "" ? current : next + "," + current;
                }
                current = "";
            } else {
                current += ch;
            }
        }
        if (current != "" && current != token) {
            next = next == "" ? current : next + "," + current;
        }
        Application.Storage.setValue(key, next);
        if (key == COMPLETED_KEY) {
            writeTodayHistory();
        }
        return next;
    }

    function setValue(key, value) {
        Application.Storage.setValue(key, value);
        if (key == COMPLETED_KEY) {
            writeTodayHistory();
        }
    }

    function writeTodayHistory() {
        Application.Storage.setValue(historyKey(todayKey()), prayerMask(readString(COMPLETED_KEY, "")));
    }

    function historyMaskForOffset(dayOffset) {
        var key = dayKeyForOffset(dayOffset);
        var value = Application.Storage.getValue(historyKey(key));
        if (value == null) {
            if (dayOffset == 0) {
                return prayerMask(readString(COMPLETED_KEY, ""));
            }
            return 0;
        }
        return value;
    }

    function dayKeyForOffset(dayOffset) {
        var moment = Time.now().add(new Time.Duration(dayOffset * 86400));
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        return (safeNumber(info.year, 2026) * 10000) + (safeNumber(info.month, 1) * 100) + safeNumber(info.day, 1);
    }

    function historyKey(dayKey) {
        return HISTORY_PREFIX + dayKey;
    }

    function prayerMask(completed) {
        var mask = 0;
        if (hasToken(completed, "fajr")) {
            mask += 1;
        }
        if (hasToken(completed, "dhuhr")) {
            mask += 2;
        }
        if (hasToken(completed, "asr")) {
            mask += 4;
        }
        if (hasToken(completed, "maghrib")) {
            mask += 8;
        }
        if (hasToken(completed, "isha")) {
            mask += 16;
        }
        return mask;
    }

    function completedPrayerCount(completed) {
        var count = 0;
        if (hasToken(completed, "fajr")) {
            count += 1;
        }
        if (hasToken(completed, "dhuhr")) {
            count += 1;
        }
        if (hasToken(completed, "asr")) {
            count += 1;
        }
        if (hasToken(completed, "maghrib")) {
            count += 1;
        }
        if (hasToken(completed, "isha")) {
            count += 1;
        }
        return count;
    }

    function safeNumber(value, fallback) {
        if (value == null) {
            return fallback;
        }

        var number = ("" + value).toNumber();
        return number == null ? fallback : number;
    }
}
