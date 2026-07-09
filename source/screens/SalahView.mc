using Toybox.Graphics;
using Toybox.Timer;
using Toybox.WatchUi;

class SalahView extends WatchUi.View {
    var _minuteTimer = null;

    function initialize() {
        View.initialize();
    }

    function onShow() {
        startMinuteTimer();
    }

    function onHide() {
        stopMinuteTimer();
    }

    function startMinuteTimer() {
        if (_minuteTimer == null) {
            _minuteTimer = new Timer.Timer();
        }

        _minuteTimer.stop();
        _minuteTimer.start(method(:onMinuteTick), 60000, true);
    }

    function stopMinuteTimer() {
        if (_minuteTimer != null) {
            _minuteTimer.stop();
        }
    }

    function onMinuteTick() {
        StorageService.ensureToday();
        WatchUi.requestUpdate();
    }

    function nextScreen() {
        var screen = SalahStorage.currentScreen() + 1;
        if (screen > SalahConstants.SCREEN_LAST) {
            screen = SalahConstants.SCREEN_HOME;
        }
        SalahStorage.setCurrentScreen(screen);
        WatchUi.requestUpdate();
    }

    function previousScreen() {
        var screen = SalahStorage.currentScreen() - 1;
        if (screen < SalahConstants.SCREEN_HOME) {
            screen = SalahConstants.SCREEN_LAST;
        }
        SalahStorage.setCurrentScreen(screen);
        WatchUi.requestUpdate();
    }

    function primaryAction() {
        if (SalahStorage.currentScreen() == SalahConstants.SCREEN_TASBIH) {
            TasbihService.increment();
        } else if (SalahStorage.currentScreen() == SalahConstants.SCREEN_HOME) {
            PrayerService.toggleCurrentCompletablePrayer();
        } else {
            SalahStorage.setCurrentScreen(SalahConstants.SCREEN_HOME);
        }
    }

    function backAction() {
        if (SalahStorage.currentScreen() == SalahConstants.SCREEN_TASBIH) {
            TasbihService.reset();
        } else {
            SalahStorage.setCurrentScreen(SalahConstants.SCREEN_HOME);
        }
    }

    function onUpdate(dc) {
        try {
            PrayerService.markMissedPastPrayers();
            NotificationService.checkDueReminder();
            var screen = SalahStorage.currentScreen();
            if (screen == SalahConstants.SCREEN_PRAYER_LIST) {
                drawPrayerList(dc);
            } else if (screen == SalahConstants.SCREEN_TIMELINE) {
                drawTimeline(dc);
            } else if (screen == SalahConstants.SCREEN_TASBIH) {
                drawTasbih(dc);
            } else if (screen == SalahConstants.SCREEN_SETTINGS) {
                drawSettings(dc);
            } else if (screen == SalahConstants.SCREEN_ABOUT) {
                drawAbout(dc);
            } else {
                drawHome(dc);
            }
        } catch (ex) {
            SalahLogger.error("Render recovered");
            drawError(dc);
        }
    }

    function drawHome(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var radius = (width < height ? width : height) / 2;
        var safePad = SalahUi.max(radius / 10, 14);
        var next = CalculationService.nextPrayer();
        var hijri = HijriService.today();
        var currentPrayerKey = PrayerService.currentCompletablePrayerKey();
        var done = PrayerService.isCompleted(currentPrayerKey);
        var y = safePad;
        var titleFont = radius < 160 ? Graphics.FONT_MEDIUM : Graphics.FONT_SYSTEM_LARGE;
        var valueFont = radius < 160 ? Graphics.FONT_SMALL : Graphics.FONT_SYSTEM_MEDIUM;
        var labelFont = radius < 160 ? Graphics.FONT_TINY : Graphics.FONT_SMALL;
        var gap = SalahUi.max(radius / 24, 6);
        var moon = SalahUi.clamp(radius / 20, 6, 12);
        var progress = next.hasKey("progress") ? next["progress"] : 0;

        SalahUi.clear(dc);
        SalahUi.drawMoon(dc, centerX, y + moon, moon);
        y += moon * 2 + gap;
        SalahUi.drawText(dc, centerX, y, labelFont, "Next Prayer", SalahUi.muted());
        y += dc.getFontHeight(labelFont) + 3;
        SalahUi.drawText(dc, centerX, y, titleFont, next["name"], SalahUi.accent());
        y += dc.getFontHeight(titleFont) + gap;
        SalahUi.accentDivider(dc, centerX, y, radius);
        y += gap;
        SalahUi.drawText(dc, centerX, y, valueFont, next["time"], SalahConstants.WHITE);
        y += dc.getFontHeight(valueFont) + 2;
        SalahUi.drawText(dc, centerX, y, labelFont, next["day"], SalahUi.muted());
        y += dc.getFontHeight(labelFont) + gap;
        drawCountdown(dc, centerX, y, next["remaining"], valueFont);
        y += dc.getFontHeight(valueFont) + gap;
        drawProgressBar(dc, centerX, y, radius * 1.18, SalahUi.clamp(radius / 40, 4, 7), progress);
        y += gap + 4;
        SalahUi.drawText(dc, centerX, y, Graphics.FONT_XTINY, hijri["weekday"] + " " + hijri["day"] + " " + hijri["month"], SalahUi.muted());
        y += dc.getFontHeight(Graphics.FONT_XTINY) + 1;
        SalahUi.drawText(dc, centerX, y, Graphics.FONT_XTINY, GregorianLabel(), SalahConstants.MUTED);
        y += dc.getFontHeight(Graphics.FONT_XTINY) + 1;
        SalahUi.drawText(dc, centerX, y, Graphics.FONT_XTINY, CalculationService.FALLBACK_LOCATION, SalahConstants.MUTED);
        y += dc.getFontHeight(Graphics.FONT_XTINY) + gap;
        SalahUi.divider(dc, centerX, y, radius);
        y += gap;
        drawHomeActions(dc, centerX, y, radius, done, PrayerService.prayerName(currentPrayerKey));
    }

    function drawCountdown(dc, centerX, y, text, font) {
        var textWidth = dc.getTextWidthInPixels(text, font);
        var iconRadius = 8;
        var gap = 8;
        var groupWidth = (iconRadius * 2) + gap + textWidth;
        var iconX = centerX - (groupWidth / 2) + iconRadius;
        var iconY = y + (dc.getFontHeight(font) / 2);
        var textX = iconX + iconRadius + gap + (textWidth / 2);
        SalahUi.drawClock(dc, iconX, iconY, iconRadius);
        SalahUi.drawText(dc, textX, y, font, text, SalahConstants.WHITE);
    }

    function drawHomeActions(dc, centerX, y, radius, done, prayerName) {
        var leftX = centerX - (radius * 0.30);
        var rightX = centerX + (radius * 0.30);
        var iconRadius = SalahUi.clamp(radius / 18, 8, 13);
        var labelFont = Graphics.FONT_XTINY;
        var labelY = y + (iconRadius * 2) + 4;
        dc.setColor(SalahConstants.DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, y + 1, centerX, labelY + dc.getFontHeight(labelFont));
        SalahUi.drawCheck(dc, leftX, y + iconRadius, iconRadius, done);
        SalahUi.drawText(dc, leftX, labelY, labelFont, done ? "Done" : "Prayed", SalahConstants.WHITE);
        SalahUi.drawBeads(dc, rightX, y + iconRadius, iconRadius);
        SalahUi.drawText(dc, rightX, labelY, labelFont, "Zikr " + TasbihService.count(), SalahConstants.WHITE);
    }

    function drawPrayerList(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var radius = (width < height ? width : height) / 2;
        SalahUi.clear(dc);
        SalahUi.drawText(dc, centerX, 16, Graphics.FONT_SMALL, "Prayer List", SalahUi.muted());
        drawPrayerRows(dc, 44, height - 26, radius, false);
    }

    function drawTimeline(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var radius = (width < height ? width : height) / 2;
        SalahUi.clear(dc);
        SalahUi.drawText(dc, centerX, 16, Graphics.FONT_SMALL, "Timeline", SalahUi.muted());
        drawPrayerRows(dc, 44, height - 26, radius, true);
    }

    function drawTasbih(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var radius = (width < height ? width : height) / 2;
        var y = height / 2 - 64;
        SalahUi.clear(dc);
        SalahUi.drawText(dc, centerX, y, Graphics.FONT_SMALL, "Tasbih", SalahUi.muted());
        y += 28;
        SalahUi.drawBeads(dc, centerX, y + 32, SalahUi.clamp(radius / 7, 22, 34));
        y += 76;
        SalahUi.drawText(dc, centerX, y, Graphics.FONT_SYSTEM_LARGE, "" + TasbihService.count(), SalahUi.accent());
        y += 44;
        SalahUi.drawText(dc, centerX, y, Graphics.FONT_TINY, "Target " + TasbihService.targetLabel(), SalahUi.muted());
        y += 20;
        SalahUi.drawText(dc, centerX, y, Graphics.FONT_XTINY, "Select add  Back reset", SalahConstants.MUTED);
    }

    function drawSettings(dc) {
        var s = CalculationService.settings();
        var rows = [
            ["Calculation", s["method"]["name"]],
            ["Madhhab", s["asrHanafi"] ? "Hanafi" : "Standard"],
            ["Time", "12 hour"],
            ["Theme", SalahStorage.isHighContrast() ? "High contrast" : "AMOLED"],
            ["Font Size", "Adaptive"],
            ["Vibration", SalahStorage.isVibrationOnly() ? "Only" : "On"],
            ["Notifications", NotificationService.reminderLabel()],
            ["Brightness", "Auto"]
        ];
        drawSettingsRows(dc, rows);
    }

    function drawAbout(dc) {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        SalahUi.clear(dc);
        SalahUi.drawMoon(dc, centerX, centerY - 56, 14);
        SalahUi.drawText(dc, centerX, centerY - 24, Graphics.FONT_SYSTEM_MEDIUM, "Salah", SalahUi.accent());
        SalahUi.drawText(dc, centerX, centerY + 6, Graphics.FONT_SMALL, "Companion", SalahConstants.WHITE);
        SalahUi.drawText(dc, centerX, centerY + 34, Graphics.FONT_TINY, "Private beta 1.0.0", SalahUi.muted());
        SalahUi.drawText(dc, centerX, centerY + 52, Graphics.FONT_XTINY, "Local-first Garmin app", SalahConstants.MUTED);
    }

    function drawPrayerRows(dc, top, bottom, radius, timeline) {
        var schedule = CalculationService.todaySchedule();
        var next = CalculationService.nextPrayer();
        var currentKey = CalculationService.currentPrayerKey();
        var rowH = (bottom - top) / schedule.size();
        var left = dc.getWidth() / 2 - (radius * 0.58);
        var right = dc.getWidth() / 2 + (radius * 0.58);
        var iconR = SalahUi.clamp(rowH / 5, 4, 8);

        for (var i = 0; i < schedule.size(); i += 1) {
            var row = schedule[i];
            var y = top + (i * rowH);
            var textY = y + ((rowH - dc.getFontHeight(Graphics.FONT_TINY)) / 2);
            var isNext = row["key"] == next["key"];
            var isCurrent = row["key"] == currentKey;
            var isDone = PrayerService.isCompletable(row["key"]) && (PrayerService.isCompleted(row["key"]) || CalculationService.currentMinutes() > row["minutes"]);
            var color = isNext ? SalahUi.accent() : (isCurrent ? SalahConstants.WHITE : (isDone ? SalahConstants.MUTED : SalahUi.muted()));

            if (timeline) {
                dc.setColor(isDone || isNext ? SalahConstants.SOFT_ACCENT : SalahConstants.DIM, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(left + iconR, y, left + iconR, y + rowH);
            }

            drawPrayerIcon(dc, left + iconR, y + (rowH / 2), iconR, row["key"], color);
            SalahUi.drawLeftText(dc, left + (iconR * 3), textY, Graphics.FONT_TINY, row["name"], color);
            dc.setColor(isNext ? SalahConstants.WHITE : SalahConstants.MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(right, textY, Graphics.FONT_TINY, row["time"], Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    function drawSettingsRows(dc, rows) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var radius = (width < height ? width : height) / 2;
        var y = 16;
        var top = 44;
        var bottom = height - 24;
        var rowH = (bottom - top) / rows.size();
        var left = centerX - (radius * 0.56);
        var right = centerX + (radius * 0.56);

        SalahUi.clear(dc);
        SalahUi.drawText(dc, centerX, y, Graphics.FONT_SMALL, "Settings", SalahUi.muted());

        for (var i = 0; i < rows.size(); i += 1) {
            var row = rows[i];
            var textY = top + (i * rowH) + ((rowH - dc.getFontHeight(Graphics.FONT_XTINY)) / 2);
            SalahUi.drawLeftText(dc, left, textY, Graphics.FONT_XTINY, row[0], SalahUi.muted());
            dc.setColor(SalahConstants.WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(right, textY, Graphics.FONT_XTINY, row[1], Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    function drawProgressBar(dc, centerX, y, width, height, percent) {
        var left = centerX - (width / 2);
        var fill = (width * percent) / 100;
        dc.setColor(SalahConstants.DIM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(height);
        dc.drawLine(left, y, left + width, y);
        dc.setColor(SalahUi.accent(), Graphics.COLOR_TRANSPARENT);
        dc.drawLine(left, y, left + fill, y);
        dc.setPenWidth(1);
    }

    function drawPrayerIcon(dc, x, y, radius, key, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        if (key == "sunrise") {
            dc.drawCircle(x, y, radius);
            dc.drawLine(x - radius, y + radius, x + radius, y + radius);
        } else if (key == "dhuhr" || key == "asr") {
            dc.drawLine(x - radius, y + radius, x + radius, y + radius);
            dc.drawLine(x - radius, y + radius, x - radius, y);
            dc.drawLine(x + radius, y + radius, x + radius, y);
            dc.drawCircle(x, y, radius);
        } else {
            dc.setColor(color, color);
            dc.fillCircle(x, y, radius);
            dc.setColor(SalahConstants.BLACK, SalahConstants.BLACK);
            dc.fillCircle(x + (radius / 2), y - (radius / 5), radius);
        }
        dc.setPenWidth(1);
    }

    function GregorianLabel() {
        var info = Toybox.Time.Gregorian.info(Toybox.Time.now(), Toybox.Time.FORMAT_MEDIUM);
        return "" + info.month + "/" + info.day + "/" + info.year;
    }

    function drawError(dc) {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        SalahUi.clear(dc);
        SalahUi.drawText(dc, centerX, centerY - 26, Graphics.FONT_SMALL, "Salah Companion", SalahUi.accent());
        SalahUi.drawText(dc, centerX, centerY, Graphics.FONT_TINY, "Recovered safely", SalahConstants.WHITE);
        SalahUi.drawText(dc, centerX, centerY + 18, Graphics.FONT_XTINY, "Open menu to continue", SalahUi.muted());
    }
}
