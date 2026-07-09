module SalahStatsService {
    function summary() {
        var weekDone = 0;
        var monthDone = 0;
        var weekTotal = 0;
        var monthTotal = 0;
        var pausedDays = 0;
        var todayMask = StorageService.historyMaskForOffset(0);

        for (var i = 0; i < 30; i += 1) {
            var mask = StorageService.historyMaskForOffset(0 - i);
            if (mask == SalahConstants.PAUSED_HISTORY_MASK) {
                pausedDays += 1;
            } else {
                var count = completedCount(mask);
                monthDone += count;
                monthTotal += SalahConstants.COMPLETABLE_PRAYER_COUNT;
                if (i < 7) {
                    weekDone += count;
                    weekTotal += SalahConstants.COMPLETABLE_PRAYER_COUNT;
                }
            }
        }

        return {
            "todayDone" => completedCount(todayMask),
            "todayMissed" => WomenService.isPauseActive() ? 0 : StorageService.tokenCount(StorageService.readString(StorageService.MISSED_KEY, "")),
            "weekDone" => weekDone,
            "weekTotal" => weekTotal,
            "monthDone" => monthDone,
            "monthTotal" => monthTotal,
            "completion" => monthTotal <= 0 ? 0 : (monthDone * 100) / monthTotal,
            "currentStreak" => currentStreak(),
            "longestStreak" => longestStreak(),
            "pausedDays" => pausedDays
        };
    }

    function completedCount(mask) {
        if (mask == SalahConstants.PAUSED_HISTORY_MASK) {
            return 0;
        }

        var count = 0;
        var bits = [1, 2, 4, 8, 16];
        for (var i = 0; i < bits.size(); i += 1) {
            if ((mask & bits[i]) != 0) {
                count += 1;
            }
        }

        return count;
    }

    function currentStreak() {
        var streak = 0;
        for (var i = 0; i < 60; i += 1) {
            var mask = StorageService.historyMaskForOffset(0 - i);
            if (mask == SalahConstants.PAUSED_HISTORY_MASK) {
                continue;
            } else if (completedCount(mask) == SalahConstants.COMPLETABLE_PRAYER_COUNT) {
                streak += 1;
            } else if (i == 0 && StorageService.tokenCount(StorageService.readString(StorageService.MISSED_KEY, "")) == 0) {
                continue;
            } else {
                return streak;
            }
        }

        return streak;
    }

    function longestStreak() {
        var longest = 0;
        var run = 0;

        for (var i = 59; i >= 0; i -= 1) {
            var mask = StorageService.historyMaskForOffset(0 - i);
            if (mask == SalahConstants.PAUSED_HISTORY_MASK) {
                continue;
            } else if (completedCount(mask) == SalahConstants.COMPLETABLE_PRAYER_COUNT) {
                run += 1;
                if (run > longest) {
                    longest = run;
                }
            } else {
                run = 0;
            }
        }

        return longest;
    }
}
