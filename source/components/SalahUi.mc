using Toybox.Graphics;

module SalahUi {
    function accent() {
        return SalahStorage.isHighContrast() ? Graphics.COLOR_WHITE : SalahConstants.ACCENT;
    }

    function muted() {
        return SalahStorage.isHighContrast() ? Graphics.COLOR_WHITE : SalahConstants.MUTED;
    }

    function background() {
        return Graphics.COLOR_BLACK;
    }

    function clear(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }

    function drawText(dc, x, y, font, text, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawLeftText(dc, x, y, font, text, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function divider(dc, centerX, y, radius) {
        var line = radius * 0.55;
        dc.setColor(SalahConstants.DIM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(centerX - line, y, centerX + line, y);
    }

    function accentDivider(dc, centerX, y, radius) {
        var line = radius / 5;
        var gap = clamp(radius / 15, 7, 14);
        var dot = clamp(radius / 70, 1, 3);

        dc.setColor(SalahConstants.SOFT_ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(centerX - line, y, centerX - gap, y);
        dc.drawLine(centerX + gap, y, centerX + line, y);
        dc.setColor(accent(), accent());
        dc.fillCircle(centerX, y, dot);
    }

    function drawMoon(dc, x, y, radius) {
        dc.setColor(accent(), accent());
        dc.fillCircle(x, y, radius);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(x + (radius / 2), y - (radius / 5), radius);
    }

    function drawClock(dc, x, y, radius) {
        dc.setColor(accent(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x, y, radius);
        dc.drawLine(x, y, x, y - (radius / 2));
        dc.drawLine(x, y, x + (radius / 2), y);
        dc.setPenWidth(1);
    }

    function drawCheck(dc, x, y, radius, checked) {
        var color = checked ? accent() : SalahConstants.MUTED;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x, y, radius);
        if (checked) {
            dc.drawLine(x - (radius / 2), y, x - (radius / 8), y + (radius / 3));
            dc.drawLine(x - (radius / 8), y + (radius / 3), x + (radius / 2), y - (radius / 3));
        }
        dc.setPenWidth(1);
    }

    function drawBeads(dc, x, y, radius) {
        var bead = max(radius / 4, 2);
        dc.setColor(accent(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x, y, radius);
        dc.setPenWidth(1);
        dc.drawCircle(x, y - radius, bead);
        dc.drawCircle(x + radius, y, bead);
        dc.drawCircle(x, y + radius, bead);
        dc.drawCircle(x - radius, y, bead);
    }

    function drawProgress(dc, x, y, radius, percent) {
        dc.setColor(SalahConstants.DIM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawCircle(x, y, radius);
        dc.setColor(accent(), Graphics.COLOR_TRANSPARENT);
        var end = (percent * 360) / 100;
        for (var a = 0; a < end; a += 12) {
            var px = x + (radius * cosDeg(a)) / 100;
            var py = y + (radius * sinDeg(a)) / 100;
            dc.fillCircle(px, py, 2);
        }
        dc.setPenWidth(1);
    }

    function drawCompass(dc, centerX, centerY, radius, bearing, headingAvailable) {
        dc.setColor(SalahConstants.DIM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(centerX, centerY, radius);
        dc.setPenWidth(1);

        drawText(dc, centerX, centerY - radius + 6, Graphics.FONT_TINY, "N", muted());
        drawText(dc, centerX + radius - 8, centerY - 6, Graphics.FONT_TINY, "E", muted());
        drawText(dc, centerX, centerY + radius - 18, Graphics.FONT_TINY, "S", muted());
        drawText(dc, centerX - radius + 8, centerY - 6, Graphics.FONT_TINY, "W", muted());

        var angle = bearing - 90;
        var tipX = centerX + (radius * 75 * cosDeg(angle)) / 10000;
        var tipY = centerY + (radius * 75 * sinDeg(angle)) / 10000;
        dc.setColor(headingAvailable ? accent() : SalahConstants.WARNING, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(centerX, centerY, tipX, tipY);
        dc.fillCircle(tipX, tipY, 4);
        dc.setPenWidth(1);
    }

    function cosDeg(angle) {
        var normalized = normalizeAngle(angle);
        if (normalized == 0) { return 100; }
        if (normalized == 90) { return 0; }
        if (normalized == 180) { return -100; }
        if (normalized == 270) { return 0; }
        if (normalized < 90) { return 100 - normalized; }
        if (normalized < 180) { return -(normalized - 90); }
        if (normalized < 270) { return -(100 - (normalized - 180)); }
        return normalized - 270;
    }

    function sinDeg(angle) {
        return cosDeg(angle - 90);
    }

    function normalizeAngle(angle) {
        while (angle < 0) {
            angle += 360;
        }
        while (angle >= 360) {
            angle -= 360;
        }
        return angle;
    }

    function clamp(value, low, high) {
        if (value < low) {
            return low;
        }
        if (value > high) {
            return high;
        }
        return value;
    }

    function max(a, b) {
        return a > b ? a : b;
    }
}
