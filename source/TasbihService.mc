using Toybox.Attention;

module TasbihService {
    const TARGETS = [33, 99, 0];

    function count() {
        return StorageService.readNumber(StorageService.TASBIH_COUNT_KEY, 0);
    }

    function target() {
        var index = StorageService.readNumber(StorageService.TASBIH_TARGET_KEY, 0);
        if (index < 0 || index >= TARGETS.size()) {
            index = 0;
        }
        return TARGETS[index];
    }

    function targetLabel() {
        var value = target();
        return value == 0 ? "Unlimited" : "" + value;
    }

    function increment() {
        var next = count() + 1;
        var limit = target();
        if (limit > 0 && next > limit) {
            next = 1;
        }
        StorageService.setValue(StorageService.TASBIH_COUNT_KEY, next);
        if (limit > 0 && next == limit && NotificationService.vibrationEnabled() && !WomenService.isPauseActive()) {
            Attention.vibrate([new Attention.VibeProfile(70, 180)]);
        }
        return next;
    }

    function reset() {
        StorageService.setValue(StorageService.TASBIH_COUNT_KEY, 0);
    }

    function cycleTarget() {
        var index = StorageService.readNumber(StorageService.TASBIH_TARGET_KEY, 0) + 1;
        if (index >= TARGETS.size()) {
            index = 0;
        }
        StorageService.setValue(StorageService.TASBIH_TARGET_KEY, index);
        reset();
    }
}
