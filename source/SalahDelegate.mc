using Toybox.WatchUi;

class SalahDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        SalahStore.addZikr(1);
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() {
        SalahStore.toggleCurrentPrayer();
        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SalahMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
}
