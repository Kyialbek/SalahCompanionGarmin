module PrayerService {
    function boot() {
        StorageService.ensureToday();
        markMissedPastPrayers();
    }

    function allPrayers() {
        return CalculationService.PRAYERS;
    }

    function isCompleted(key) {
        if (WomenService.isPauseActive()) {
            return false;
        }
        if (!isCompletable(key)) {
            return false;
        }
        StorageService.ensureToday();
        return StorageService.hasToken(StorageService.readString(StorageService.COMPLETED_KEY, ""), key);
    }

    function isMissed(key) {
        StorageService.ensureToday();
        return StorageService.hasToken(StorageService.readString(StorageService.MISSED_KEY, ""), key);
    }

    function togglePrayer(key) {
        if (WomenService.isPauseActive()) {
            return;
        }

        if (!isCompletable(key)) {
            return;
        }

        StorageService.ensureToday();
        if (isCompleted(key)) {
            StorageService.removeToken(StorageService.COMPLETED_KEY, key);
        } else {
            StorageService.addToken(StorageService.COMPLETED_KEY, key);
            StorageService.removeToken(StorageService.MISSED_KEY, key);
        }
    }

    function toggleCurrentPrayer() {
        toggleCurrentCompletablePrayer();
    }

    function toggleCurrentCompletablePrayer() {
        togglePrayer(currentCompletablePrayerKey());
    }

    function currentCompletablePrayerKey() {
        var minutes = CalculationService.currentMinutes();
        var schedule = CalculationService.todaySchedule();
        var current = "fajr";

        for (var i = 0; i < schedule.size(); i += 1) {
            var key = schedule[i]["key"];
            if (minutes >= schedule[i]["minutes"] && isCompletable(key)) {
                current = key;
            }
        }

        return current;
    }

    function markMissedPastPrayers() {
        StorageService.ensureToday();
        if (WomenService.isPauseActive()) {
            StorageService.setValue(StorageService.MISSED_KEY, "");
            return;
        }

        var minutes = CalculationService.currentMinutes();
        var schedule = CalculationService.todaySchedule();
        for (var i = 0; i < schedule.size(); i += 1) {
            var prayer = schedule[i];
            if (isCompletable(prayer["key"]) && minutes > prayer["minutes"] + 90 && !isCompleted(prayer["key"])) {
                StorageService.addToken(StorageService.MISSED_KEY, prayer["key"]);
            }
        }
    }

    function resetToday() {
        StorageService.setValue(StorageService.COMPLETED_KEY, "");
        StorageService.setValue(StorageService.MISSED_KEY, "");
        StorageService.writeTodayHistory();
    }

    function summary() {
        markMissedPastPrayers();
        var completed = StorageService.completedPrayerCount(StorageService.readString(StorageService.COMPLETED_KEY, ""));
        var missed = StorageService.tokenCount(StorageService.readString(StorageService.MISSED_KEY, ""));
        return {
            "completed" => completed,
            "missed" => missed,
            "currentStreak" => StorageService.readNumber(StorageService.CURRENT_STREAK_KEY, 0),
            "longestStreak" => StorageService.readNumber(StorageService.LONGEST_STREAK_KEY, 0)
        };
    }

    function isCompletable(key) {
        return key == "fajr" || key == "dhuhr" || key == "asr" || key == "maghrib" || key == "isha";
    }

    function prayerName(key) {
        if (key == "fajr") {
            return "Fajr";
        } else if (key == "dhuhr") {
            return "Dhuhr";
        } else if (key == "asr") {
            return "Asr";
        } else if (key == "maghrib") {
            return "Maghrib";
        } else if (key == "isha") {
            return "Isha";
        }

        return "Prayer";
    }
}
