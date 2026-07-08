using Toybox.WatchUi;

class SalahMenuDelegate extends WatchUi.MenuInputDelegate {
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :reset_zikr) {
            SalahStore.resetZikr();
        } else if (item == :reset_prayer) {
            SalahStore.resetPrayer();
        }

        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }
}
