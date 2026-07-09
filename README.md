# Salah Companion for Garmin

This is a Garmin Connect IQ watch app written in Monkey C.

It is separate from the Next.js phone/web app because Garmin watches cannot install or run the web/PWA version directly.

## Current Features

- Shows the next salah for Naperville, Illinois using a lightweight solar prayer calculation service with ISNA/MWL/Umm Al-Qura/Karachi-style method settings.
- Shows the next prayer time and countdown.
- Refreshes the countdown automatically every minute.
- Tracks each daily prayer separately: Fajr, Dhuhr, Asr, Maghrib, Isha.
- Resets daily prayer completion automatically when the watch date changes.
- Press Select on Home to toggle the current completable prayer.
- Press Select on Tasbih to increment zikr.
- Press Back on Tasbih to reset zikr; Back on other screens returns Home.
- Press Up/Down to move through Home, Prayer List, Timeline, Tasbih, Settings, and About.
- Uses Naperville, IL fallback coordinates when no synced location is available.

## Build

Install Garmin Connect IQ SDK, then from this folder run a command like:

```bash
monkeyc -f monkey.jungle -o bin/SalahCompanion.prg -y developer_key.der
```

You need a Garmin developer key and a supported target device from `manifest.xml`.

## Install on a Physical Garmin Watch

Supported tested device: Garmin fēnix E 47 mm AMOLED

Build target used: `fenixe`

Final Connect IQ package to upload/share:

```text
bin/SalahCompanion.iq
```

Garmin Express can detect the watch, but on newer Garmin firmware it may not sideload local `.prg` or `.iq` files directly. Manual MTP copying to `GARMIN/Apps` can leave the file on the watch without making the app appear in Apps / Activities.

For a paired fēnix E, use the official Connect IQ ecosystem:

1. Confirm the watch is paired and syncing in Garmin Connect on the phone.
2. Build the signed package:

```bash
monkeyc -e -f monkey.jungle -o bin/SalahCompanion.iq -y keys/developer_key.der
```

3. Upload `bin/SalahCompanion.iq` in the Garmin Connect IQ developer portal.
4. Create a private beta or unpublished test listing.
5. Add the Garmin account used by the phone/watch as a tester.
6. Install Salah Companion from Connect IQ on the paired phone/watch.
7. Sync the watch, then open `Apps / Activities` and launch Salah Companion.

Local PRG build for troubleshooting:

```bash
"/Users/apple/Documents/SalahCompanionGarmin/.local-jdk/Contents/Home/bin/java" -Xms128m -Djava.awt.headless=true -Dfile.encoding=UTF-8 -classpath "/Users/apple/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.2.0-2026-06-09-92a1605b2/bin/monkeybrains.jar" com.garmin.monkeybrains.Monkeybrains -d fenixe -f monkey.jungle -o bin/SALAH.PRG -y keys/developer_key.der
```

If testing manual MTP copy anyway:

1. Unlock the Garmin watch.
2. Connect it to the Mac via USB.
3. Choose File Transfer / MTP mode on the watch if prompted.
4. Upload the device-specific PRG:

```text
bin/SALAH.PRG
```

to:

```text
GARMIN/Apps/SALAH.PRG
```

5. Optionally create:

```text
GARMIN/Apps/LOGS/SALAH.TXT
```

6. Unplug the watch.
7. Wait 20-30 seconds.
8. Restart the watch.
9. Open the watch app list and look for Salah Companion.

Troubleshooting:

- If `/Volumes/GARMIN` does not appear on macOS, use MTP instead.
- `monkeydo` and `mdd` are simulator/debug tools, not physical deployment tools.
- Garmin Express detects the watch but does not provide a reliable local sideload flow for this device.
- ADB is not applicable.
- The watch must be unlocked before MTP access works.
- If `SALAH.PRG` is visible over MTP but the app is missing on the watch after restart, use the Connect IQ private beta route.

## Install

For local testing, use Garmin Connect IQ simulator or Garmin's sideload/debug workflow for your watch model.

For sharing with friends, send the signed package at:

```text
bin/SalahCompanion.iq
```

See `INSTALL.md` for private sharing and manual installation notes.

## Notes

This Garmin app is a lightweight watch companion. It does not request GPS/location permission yet; it uses stored/default Naperville coordinates and defensive timezone handling for simulator, DST, reboot, and missing date fields.

## Simulator Test Checklist

Build commands used for the current app:

```bash
"/Users/apple/Documents/SalahCompanionGarmin/.local-jdk/Contents/Home/bin/java" -Xms128m -Djava.awt.headless=true -Dfile.encoding=UTF-8 -classpath "/Users/apple/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.2.0-2026-06-09-92a1605b2/bin/monkeybrains.jar" com.garmin.monkeybrains.Monkeybrains -d fenixe -f monkey.jungle -o bin/SalahCompanion-fenixe.prg -y keys/developer_key.der
"/Users/apple/Documents/SalahCompanionGarmin/.local-jdk/Contents/Home/bin/java" -Xms128m -Djava.awt.headless=true -Dfile.encoding=UTF-8 -classpath "/Users/apple/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.2.0-2026-06-09-92a1605b2/bin/monkeybrains.jar" com.garmin.monkeybrains.Monkeybrains -d vivoactive5 -f monkey.jungle -o bin/SalahCompanion-vivoactive5.prg -y keys/developer_key.der
```

Simulator checks:

- fēnix E (`fenixe`): launch with `monkeydo bin/SalahCompanion-fenixe.prg fenixe`; verify no IQ error, Home shows Hijri date at top, countdown, progress bar, and action row inside the round display.
- vívoactive 5 (`vivoactive5`): launch with `monkeydo bin/SalahCompanion-vivoactive5.prg vivoactive5`; leave open past one minute and verify no crash or frozen countdown.
- Large round screen (`fenix7x`): launch with `monkeydo bin/SalahCompanion-fenix7x.prg fenix7x`; verify text remains centered and not clipped.
- Press Up/Down through Home, Prayer List, Timeline, Tasbih, Settings, About.
- On Home, Select toggles the current completable prayer only. Sunrise is never stored as completed.
- On Tasbih, Select increments and Back resets.
- Restart/relaunch the simulator and verify stored prayers/tasbih load without corruption.
- Change watch/system day or relaunch after date rollover and verify daily completion resets.
