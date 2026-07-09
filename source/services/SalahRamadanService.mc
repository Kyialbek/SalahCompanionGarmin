module SalahRamadanService {
    function today() {
        var schedule = CalculationService.todaySchedule();
        var now = CalculationService.currentMinutes();
        var fajr = schedule[0]["minutes"];
        var maghrib = schedule[4]["minutes"];
        var suhoorDelta = fajr - now;
        var iftarDelta = maghrib - now;

        if (suhoorDelta < 0) {
            suhoorDelta += 1440;
        }

        if (iftarDelta < 0) {
            iftarDelta += 1440;
        }

        return {
            "ramadanDay" => ramadanDay(),
            "fasting" => SalahTimeUtils.durationText(maghrib - fajr),
            "suhoor" => SalahTimeUtils.durationText(suhoorDelta),
            "iftar" => SalahTimeUtils.durationText(iftarDelta),
            "fajrTime" => CalculationService.formatMinutes(fajr),
            "maghribTime" => CalculationService.formatMinutes(maghrib),
            "isFastingWindow" => now >= fajr && now < maghrib
        };
    }

    function ramadanDay() {
        var hijri = HijriService.today();
        if (hijri["month"] == "Ramadan") {
            return "" + hijri["day"];
        }
        return "Estimate";
    }
}
