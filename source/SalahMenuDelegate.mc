using Toybox.WatchUi;

class SalahMenuDelegate extends WatchUi.MenuInputDelegate {
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :home) {
            SalahStorage.setCurrentScreen(SalahConstants.SCREEN_HOME);
        } else if (item == :qibla) {
            SalahStorage.setCurrentScreen(SalahConstants.SCREEN_QIBLA);
        } else if (item == :ramadan) {
            SalahStorage.setCurrentScreen(SalahConstants.SCREEN_RAMADAN);
        } else if (item == :stats) {
            SalahStorage.setCurrentScreen(SalahConstants.SCREEN_STATS);
        } else if (item == :high_contrast) {
            SalahStorage.toggleHighContrast();
        } else if (item == :vibration_only) {
            SalahStorage.toggleVibrationOnly();
        } else if (item == :time_format) {
            StorageService.setValue(StorageService.TIME_FORMAT_KEY, !StorageService.readBool(StorageService.TIME_FORMAT_KEY, false));
        } else if (item == :vibration_toggle) {
            NotificationService.toggleVibration();
        } else if (item == :reminders_toggle) {
            NotificationService.toggleReminders();
        } else if (item == :women_mode) {
            WomenService.toggleEnabled();
        } else if (item == :period_pause) {
            WomenService.togglePause();
        } else if (item == :reset_zikr) {
            TasbihService.reset();
        } else if (item == :target_zikr) {
            TasbihService.cycleTarget();
        } else if (item == :reset_prayers) {
            PrayerService.resetToday();
        } else if (item == :toggle_fajr) {
            PrayerService.togglePrayer("fajr");
        } else if (item == :toggle_dhuhr) {
            PrayerService.togglePrayer("dhuhr");
        } else if (item == :toggle_asr_prayer) {
            PrayerService.togglePrayer("asr");
        } else if (item == :toggle_maghrib) {
            PrayerService.togglePrayer("maghrib");
        } else if (item == :toggle_isha) {
            PrayerService.togglePrayer("isha");
        } else if (item == :calc_method) {
            CalculationService.cycleMethod();
        } else if (item == :asr_madhhab) {
            CalculationService.toggleAsr();
        } else if (item == :reminder_offset) {
            NotificationService.cycleReminder();
        }

        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }
}
