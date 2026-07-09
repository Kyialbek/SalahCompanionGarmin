using Toybox.WatchUi;

class SalahDelegate extends WatchUi.BehaviorDelegate {
    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onPreviousPage() {
        _view.previousScreen();
        return true;
    }

    function onNextPage() {
        _view.nextScreen();
        return true;
    }

    function onSelect() {
        _view.primaryAction();
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() {
        _view.backAction();
        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SalahMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
}
