using Toybox.Graphics;
using Toybox.WatchUi;

class SalahView extends WatchUi.View {
    const ACCENT = 0x55D68A;
    const SOFT_ACCENT = 0x3FA66C;
    const MUTED = 0xAEB4BC;
    const DIM = 0x2A2F35;

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var radius = (width < height ? width : height) / 2;
        var next = SalahTimes.nextPrayer();
        var done = SalahStore.isPrayerDone(next["key"]);
        var layout = buildLayout(dc, width, height, radius, next);
        var y = layout["top"];

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawMoon(dc, centerX, y + layout["moonRadius"], layout["moonRadius"]);
        y += layout["moonRadius"] * 2 + layout["smallGap"];

        drawText(dc, centerX, y, layout["labelFont"], "Next Prayer", MUTED);
        y += layout["labelHeight"] + layout["gap"];

        drawText(dc, centerX, y, layout["nameFont"], next["name"], ACCENT);
        y += layout["nameHeight"] + layout["gap"];

        drawAccentDivider(dc, centerX, y + (layout["dividerHeight"] / 2), radius);
        y += layout["dividerHeight"] + layout["gap"];

        drawText(dc, centerX, y, layout["valueFont"], next["time"], Graphics.COLOR_WHITE);
        y += layout["valueHeight"] + layout["smallGap"];

        drawText(dc, centerX, y, layout["labelFont"], next["day"], MUTED);
        y += layout["labelHeight"] + layout["gap"];

        drawCountdown(dc, centerX, y, layout["clockRadius"], next["remaining"], layout["valueFont"], layout["valueHeight"], dc.getTextWidthInPixels(next["remaining"], layout["valueFont"]));
        y += max(layout["clockRadius"] * 2, layout["valueHeight"]) + layout["smallGap"];

        drawText(dc, centerX, y, layout["labelFont"], "Remaining", MUTED);
        y += layout["labelHeight"] + layout["gap"];

        drawNeutralDivider(dc, centerX, y + (layout["bottomDividerHeight"] / 2), radius);
        y += layout["bottomDividerHeight"] + layout["gap"];

        drawActions(dc, centerX, y, radius, layout["actionRadius"], layout["actionFont"], layout["actionHeight"], done);
    }

    function buildLayout(dc, width, height, radius, next) {
        var safePad = max(radius / 10, 14);
        var labelFont = Graphics.FONT_SMALL;
        var actionFont = Graphics.FONT_XTINY;
        var nameFont = Graphics.FONT_SYSTEM_LARGE;
        var valueFont = Graphics.FONT_SYSTEM_MEDIUM;
        var gap = max(radius / 24, 7);
        var smallGap = max(gap / 2, 3);
        var moonRadius = clamp(radius / 20, 6, 12);
        var clockRadius = clamp(radius / 24, 5, 10);
        var actionRadius = clamp(radius / 19, 7, 12);
        var dividerHeight = max(radius / 28, 5);
        var bottomDividerHeight = max(radius / 28, 5);
        var bottomLift = max(radius / 20, 10) + 10;
        var usableHeight = height - (safePad * 2);
        var usableWidth = width - (safePad * 2);

        if (radius < 160) {
            labelFont = Graphics.FONT_TINY;
            valueFont = Graphics.FONT_SMALL;
            gap = max(radius / 30, 5);
            smallGap = max(gap / 2, 2);
            bottomLift = max(radius / 18, 10) + 10;
        }

        if (dc.getTextWidthInPixels(next["name"], nameFont) > usableWidth) {
            nameFont = Graphics.FONT_LARGE;
        }

        if (dc.getTextWidthInPixels(next["name"], nameFont) > usableWidth) {
            nameFont = Graphics.FONT_MEDIUM;
        }

        if (dc.getTextWidthInPixels(next["time"], valueFont) > usableWidth || dc.getTextWidthInPixels(next["remaining"], valueFont) > usableWidth) {
            valueFont = Graphics.FONT_SMALL;
        }

        var labelHeight = dc.getFontHeight(labelFont);
        var actionHeight = dc.getFontHeight(actionFont);
        var nameHeight = dc.getFontHeight(nameFont);
        var valueHeight = dc.getFontHeight(valueFont);
        var totalHeight = measuredHeight(labelHeight, actionHeight, nameHeight, valueHeight, moonRadius, clockRadius, actionRadius, gap, smallGap, dividerHeight, bottomDividerHeight, bottomLift);

        while (totalHeight > usableHeight && gap > 3) {
            gap -= 1;
            smallGap = max(gap / 2, 2);
            moonRadius = max(moonRadius - 1, 4);
            clockRadius = max(clockRadius - 1, 4);
            actionRadius = max(actionRadius - 1, 7);
            dividerHeight = max(dividerHeight - 1, 4);
            bottomDividerHeight = max(bottomDividerHeight - 1, 4);
            bottomLift = max(bottomLift - 1, 4);
            totalHeight = measuredHeight(labelHeight, actionHeight, nameHeight, valueHeight, moonRadius, clockRadius, actionRadius, gap, smallGap, dividerHeight, bottomDividerHeight, bottomLift);
        }

        if (totalHeight > usableHeight) {
            labelFont = Graphics.FONT_TINY;
            labelHeight = dc.getFontHeight(labelFont);
            totalHeight = measuredHeight(labelHeight, actionHeight, nameHeight, valueHeight, moonRadius, clockRadius, actionRadius, gap, smallGap, dividerHeight, bottomDividerHeight, bottomLift);
        }

        if (totalHeight > usableHeight) {
            nameFont = Graphics.FONT_MEDIUM;
            valueFont = Graphics.FONT_SMALL;
            nameHeight = dc.getFontHeight(nameFont);
            valueHeight = dc.getFontHeight(valueFont);
            totalHeight = measuredHeight(labelHeight, actionHeight, nameHeight, valueHeight, moonRadius, clockRadius, actionRadius, gap, smallGap, dividerHeight, bottomDividerHeight, bottomLift);
        }

        while (totalHeight > usableHeight && moonRadius > 0) {
            moonRadius -= 1;
            clockRadius = max(clockRadius - 1, 3);
            actionRadius = max(actionRadius - 1, 6);
            gap = max(gap - 1, 2);
            smallGap = max(gap / 2, 1);
            bottomLift = max(bottomLift - 1, 6);
            totalHeight = measuredHeight(labelHeight, actionHeight, nameHeight, valueHeight, moonRadius, clockRadius, actionRadius, gap, smallGap, dividerHeight, bottomDividerHeight, bottomLift);
        }

        var top = (height - totalHeight) / 2;
        if (top < safePad) {
            top = safePad;
        }

        return {
            "top" => top,
            "labelFont" => labelFont,
            "actionFont" => actionFont,
            "nameFont" => nameFont,
            "valueFont" => valueFont,
            "labelHeight" => labelHeight,
            "actionHeight" => actionHeight,
            "nameHeight" => nameHeight,
            "valueHeight" => valueHeight,
            "gap" => gap,
            "smallGap" => smallGap,
            "moonRadius" => moonRadius,
            "clockRadius" => clockRadius,
            "actionRadius" => actionRadius,
            "dividerHeight" => dividerHeight,
            "bottomDividerHeight" => bottomDividerHeight
        };
    }

    function measuredHeight(labelHeight, actionLabelHeight, nameHeight, valueHeight, moonRadius, clockRadius, actionRadius, gap, smallGap, dividerHeight, bottomDividerHeight, bottomLift) {
        var actionHeight = (actionRadius * 2) + smallGap + actionLabelHeight;
        return (moonRadius * 2) + smallGap + labelHeight + gap +
            nameHeight + gap +
            dividerHeight + gap +
            valueHeight + smallGap +
            labelHeight + gap +
            max(clockRadius * 2, valueHeight) + smallGap +
            labelHeight + gap +
            bottomDividerHeight + gap +
            actionHeight +
            bottomLift;
    }

    function drawText(dc, x, y, font, text, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawMoon(dc, x, y, radius) {
        dc.setColor(ACCENT, ACCENT);
        dc.fillCircle(x, y, radius);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(x + (radius / 2), y - (radius / 5), radius);
    }

    function drawAccentDivider(dc, x, y, radius) {
        var line = radius / 5;
        var gap = clamp(radius / 15, 7, 14);
        var dot = clamp(radius / 70, 1, 3);

        dc.setColor(SOFT_ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(x - line, y, x - gap, y);
        dc.drawLine(x + gap, y, x + line, y);
        dc.setColor(ACCENT, ACCENT);
        dc.fillCircle(x, y, dot);
    }

    function drawCountdown(dc, centerX, y, iconRadius, text, font, textHeight, textWidth) {
        var gap = max(iconRadius, 5);
        var groupWidth = (iconRadius * 2) + gap + textWidth;
        var iconX = centerX - (groupWidth / 2) + iconRadius;
        var iconY = y + (textHeight / 2);
        var textX = iconX + iconRadius + gap + (textWidth / 2);

        drawClock(dc, iconX, iconY, iconRadius);
        drawText(dc, textX, y, font, text, Graphics.COLOR_WHITE);
    }

    function drawClock(dc, x, y, radius) {
        dc.setColor(ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x, y, radius);
        dc.drawLine(x, y, x, y - (radius / 2));
        dc.drawLine(x, y, x + (radius / 2), y);
        dc.setPenWidth(1);
    }

    function drawNeutralDivider(dc, x, y, radius) {
        var line = radius * 0.58;
        dc.setColor(DIM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(x - line, y, x + line, y);
    }

    function drawActions(dc, centerX, y, radius, iconRadius, labelFont, labelHeight, done) {
        var leftX = centerX - (radius * 0.29);
        var rightX = centerX + (radius * 0.29);
        var labelY = y + (iconRadius * 2) + 3;
        var dividerBottom = labelY + labelHeight;
        var prayedColor = done ? ACCENT : ACCENT;

        dc.setColor(DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, y + 1, centerX, dividerBottom);

        drawCheck(dc, leftX, y + iconRadius, iconRadius, prayedColor);
        drawText(dc, leftX, labelY, labelFont, "Prayed", Graphics.COLOR_WHITE);

        drawBeads(dc, rightX, y + iconRadius, iconRadius);
        drawText(dc, rightX, labelY, labelFont, "Zikr", Graphics.COLOR_WHITE);
    }

    function drawCheck(dc, x, y, radius, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x, y, radius);
        dc.drawLine(x - (radius / 2), y, x - (radius / 8), y + (radius / 3));
        dc.drawLine(x - (radius / 8), y + (radius / 3), x + (radius / 2), y - (radius / 3));
        dc.setPenWidth(1);
    }

    function drawBeads(dc, x, y, radius) {
        var bead = max(radius / 4, 2);
        dc.setColor(ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(x, y, radius);
        dc.setPenWidth(1);
        dc.drawCircle(x, y - radius, bead);
        dc.drawCircle(x + radius, y, bead);
        dc.drawCircle(x, y + radius, bead);
        dc.drawCircle(x - radius, y, bead);
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
