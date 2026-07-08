using Toybox.Application;
using Toybox.WatchUi;

class SalahCompanionApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new SalahView(), new SalahDelegate() ];
    }
}
