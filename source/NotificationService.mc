using Toybox.Attention;

module NotificationService {
    const OFFSETS = [-1, 30, 15, 5, 0];

    function boot() {
        checkDueReminder();
    }

    function cycleReminder() {
        var current = StorageService.readNumber(StorageService.REMINDER_KEY, -1);
        var index = 0;
        for (var i = 0; i < OFFSETS.size(); i += 1) {
            if (OFFSETS[i] == current) {
                index = i + 1;
            }
        }
        if (index >= OFFSETS.size()) {
            index = 0;
        }
        StorageService.setValue(StorageService.REMINDER_KEY, OFFSETS[index]);
    }

    function reminderLabel() {
        var offset = StorageService.readNumber(StorageService.REMINDER_KEY, -1);
        if (offset < 0) {
            return "Off";
        }
        if (offset == 0) {
            return "At time";
        }
        return offset + " min";
    }

    function checkDueReminder() {
        if (!remindersEnabled() || WomenService.isPauseActive()) {
            return;
        }

        var offset = StorageService.readNumber(StorageService.REMINDER_KEY, -1);
        if (offset < 0) {
            return;
        }

        var now = CalculationService.currentMinutes();
        var schedule = CalculationService.todaySchedule();
        for (var i = 0; i < schedule.size(); i += 1) {
            var prayer = schedule[i];
            if (!PrayerService.isCompletable(prayer["key"])) {
                continue;
            }
            var due = prayer["minutes"] - offset;
            if (now >= due && now <= due + 1) {
                var key = StorageService.todayKey() + ":" + prayer["key"] + ":" + offset;
                if (StorageService.readString(StorageService.LAST_REMINDER_KEY, "") != key) {
                    vibrateForOffset(offset);
                    StorageService.setValue(StorageService.LAST_REMINDER_KEY, key);
                }
            }
        }
    }

    function vibrateForOffset(offset) {
        if (!vibrationEnabled() || WomenService.isPauseActive()) {
            return;
        }

        if (offset == 0) {
            Attention.vibrate([new Attention.VibeProfile(100, 300), new Attention.VibeProfile(0, 120), new Attention.VibeProfile(100, 500)]);
        } else if (offset <= 5) {
            Attention.vibrate([new Attention.VibeProfile(80, 250), new Attention.VibeProfile(0, 100), new Attention.VibeProfile(80, 250)]);
        } else {
            Attention.vibrate([new Attention.VibeProfile(60, 350)]);
        }
    }

    function remindersEnabled() {
        return StorageService.readBool(StorageService.REMINDERS_KEY, true);
    }

    function toggleReminders() {
        StorageService.setValue(StorageService.REMINDERS_KEY, !remindersEnabled());
    }

    function vibrationEnabled() {
        return StorageService.readBool(StorageService.VIBRATION_KEY, true);
    }

    function toggleVibration() {
        StorageService.setValue(StorageService.VIBRATION_KEY, !vibrationEnabled());
    }
}
