module SalahStatsService {
    function summary() {
        var weekDone = 0;
        var monthDone = 0;
        var weekTotal = 7 * SalahConstants.PRAYER_COUNT;
        var monthTotal = 30 * SalahConstants.PRAYER_COUNT;

        for (var i = 0; i < 30; i += 1) {
            var count = completedCount(StorageService.historyMaskForOffset(0 - i));
            monthDone += count;
            if (i < 7) {
                weekDone += count;
            }
        }

        return {
            "weekDone" => weekDone,
            "weekTotal" => weekTotal,
            "monthDone" => monthDone,
            "monthTotal" => monthTotal,
            "completion" => (monthDone * 100) / monthTotal,
            "currentStreak" => currentStreak(),
            "longestStreak" => longestStreak()
        };
    }

    function completedCount(mask) {
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
            if (completedCount(StorageService.historyMaskForOffset(0 - i)) == SalahConstants.PRAYER_COUNT) {
                streak += 1;
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
            if (completedCount(StorageService.historyMaskForOffset(0 - i)) == SalahConstants.PRAYER_COUNT) {
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
