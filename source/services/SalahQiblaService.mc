using Toybox.Math;

module SalahQiblaService {
    var _heading = null;
    var _smoothedHeading = null;
    var _lastError = null;

    function qiblaBearing() {
        var settings = CalculationService.settings();
        var lat1 = degToRad(settings["lat"]);
        var lon1 = degToRad(settings["lon"]);
        var lat2 = degToRad(21.4225);
        var lon2 = degToRad(39.8262);
        var dLon = lon2 - lon1;
        var y = Math.sin(dLon) * Math.cos(lat2);
        var x = (Math.cos(lat1) * Math.sin(lat2)) - (Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon));
        var bearing = radToDeg(Math.atan2(y, x));

        while (bearing < 0) {
            bearing += 360;
        }
        while (bearing >= 360) {
            bearing -= 360;
        }

        return bearing.toNumber();
    }

    function hasHeading() {
        return _smoothedHeading != null;
    }

    function heading() {
        return _smoothedHeading == null ? 0 : _smoothedHeading;
    }

    function qiblaOffset() {
        var offset = qiblaBearing() - heading();
        while (offset < 0) {
            offset += 360;
        }

        while (offset >= 360) {
            offset -= 360;
        }

        return offset;
    }

    function updateHeading(rawHeading) {
        if (rawHeading == null) {
            _lastError = "Compass unavailable";
            return;
        }

        _heading = rawHeading;
        if (_smoothedHeading == null) {
            _smoothedHeading = rawHeading;
        } else {
            _smoothedHeading = ((_smoothedHeading * 3) + rawHeading) / 4;
        }
        _lastError = null;
    }

    function fallbackMessage() {
        if (_lastError != null) {
            return _lastError;
        }

        return "Calibrate compass";
    }

    function degToRad(value) {
        return value * Math.PI / 180.0;
    }

    function radToDeg(value) {
        return value * 180.0 / Math.PI;
    }
}
