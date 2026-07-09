using Toybox.Application;
using Toybox.System;

module SalahLogger {
    const LAST_ERROR_KEY = "last_error";

    function info(message) {
        System.println("[Salah] " + message);
    }

    function error(message) {
        Application.Storage.setValue(LAST_ERROR_KEY, message);
        System.println("[Salah:error] " + message);
    }

    function lastError() {
        var value = Application.Storage.getValue(LAST_ERROR_KEY);
        return value == null ? "" : value;
    }

    function clearError() {
        Application.Storage.setValue(LAST_ERROR_KEY, "");
    }
}
