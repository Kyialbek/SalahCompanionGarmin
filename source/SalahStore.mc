using Toybox.Application;

module SalahStore {
    const ZIKR_KEY = "zikr_count";
    const PRAYER_KEY = "prayer_done";

    function getZikr() {
        var value = Application.Storage.getValue(ZIKR_KEY);
        return value == null ? 0 : value;
    }

    function addZikr(amount) {
        Application.Storage.setValue(ZIKR_KEY, getZikr() + amount);
    }

    function resetZikr() {
        Application.Storage.setValue(ZIKR_KEY, 0);
    }

    function isPrayerDone(prayerKey) {
        var stored = Application.Storage.getValue(PRAYER_KEY);
        return stored == prayerKey;
    }

    function togglePrayer(prayerKey) {
        if (isPrayerDone(prayerKey)) {
            Application.Storage.setValue(PRAYER_KEY, "");
        } else {
            Application.Storage.setValue(PRAYER_KEY, prayerKey);
        }
    }

    function toggleCurrentPrayer() {
        var next = SalahTimes.nextPrayer();
        togglePrayer(next["key"]);
    }

    function resetPrayer() {
        Application.Storage.setValue(PRAYER_KEY, "");
    }
}
