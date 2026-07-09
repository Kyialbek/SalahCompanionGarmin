module SalahQiblaService {
    var _heading = null;
    var _smoothedHeading = null;
    var _lastError = null;

    function qiblaBearing() {
        return SalahConstants.QIBLA_BEARING_NAPERVILLE;
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
}
