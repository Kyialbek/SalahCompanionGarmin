using Toybox.Application;

module SalahStorage {
    const SCREEN_KEY = "screen";
    const HIGH_CONTRAST_KEY = "high_contrast";
    const VIBRATION_ONLY_KEY = "vibration_only";

    function currentScreen() {
        var value = Application.Storage.getValue(SCREEN_KEY);
        return value == null ? SalahConstants.SCREEN_HOME : value;
    }

    function setCurrentScreen(screen) {
        Application.Storage.setValue(SCREEN_KEY, screen);
    }

    function isHighContrast() {
        return Application.Storage.getValue(HIGH_CONTRAST_KEY) == true;
    }

    function toggleHighContrast() {
        Application.Storage.setValue(HIGH_CONTRAST_KEY, !isHighContrast());
    }

    function isVibrationOnly() {
        return Application.Storage.getValue(VIBRATION_ONLY_KEY) == true;
    }

    function toggleVibrationOnly() {
        Application.Storage.setValue(VIBRATION_ONLY_KEY, !isVibrationOnly());
    }
}
