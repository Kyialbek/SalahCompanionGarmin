module WomenService {
    function isEnabled() {
        return StorageService.readBool(StorageService.WOMEN_MODE_KEY, false);
    }

    function toggleEnabled() {
        var next = !isEnabled();
        StorageService.setValue(StorageService.WOMEN_MODE_KEY, next);
        if (!next) {
            endPause();
        }
    }

    function isPauseActive() {
        return isEnabled() && StorageService.readBool(StorageService.PAUSE_ACTIVE_KEY, false);
    }

    function togglePause() {
        if (isPauseActive()) {
            endPause();
        } else {
            startPause();
        }
    }

    function startPause() {
        StorageService.setValue(StorageService.WOMEN_MODE_KEY, true);
        StorageService.setValue(StorageService.PAUSE_ACTIVE_KEY, true);
        StorageService.setValue(StorageService.PAUSE_START_KEY, StorageService.todayKey());
        markTodayPaused();
    }

    function endPause() {
        var today = StorageService.todayKey();
        var pausedToday = StorageService.readNumber(StorageService.LAST_PAUSED_DAY_KEY, 0) == today;

        StorageService.setValue(StorageService.PAUSE_ACTIVE_KEY, false);
        if (pausedToday) {
            var days = pausedDays();
            if (days > 0) {
                StorageService.setValue(StorageService.PAUSED_DAYS_KEY, days - 1);
            }
            StorageService.setValue(StorageService.LAST_PAUSED_DAY_KEY, 0);
        }
        StorageService.writeTodayHistory();
    }

    function markTodayPaused() {
        var today = StorageService.todayKey();
        if (StorageService.readNumber(StorageService.LAST_PAUSED_DAY_KEY, 0) != today) {
            StorageService.setValue(StorageService.PAUSED_DAYS_KEY, pausedDays() + 1);
            StorageService.setValue(StorageService.LAST_PAUSED_DAY_KEY, today);
        }
        StorageService.writeTodayHistory();
    }

    function pausedDays() {
        return StorageService.readNumber(StorageService.PAUSED_DAYS_KEY, 0);
    }

    function pauseStartDate() {
        return StorageService.readNumber(StorageService.PAUSE_START_KEY, 0);
    }

    function statusLabel() {
        if (isPauseActive()) {
            return "Pause active";
        }
        return isEnabled() ? "Women Mode on" : "Women Mode off";
    }
}
