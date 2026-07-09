using Toybox.Application;
using Toybox.WatchUi;

class SalahCompanionApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        StorageService.boot();
        PrayerService.boot();
        NotificationService.boot();
    }

    function onStop(state) {
        StorageService.ensureToday();
    }

    function getInitialView() {
        var view = new SalahView();
        return [ view, new SalahDelegate(view) ];
    }
}
