# Salah Companion for Garmin

This is a Garmin Connect IQ watch app written in Monkey C.

It is separate from the Next.js phone/web app because Garmin watches cannot install or run the web/PWA version directly.

## Current Features

- Shows the next salah for Naperville, Illinois using approximate monthly Hanafi-friendly defaults.
- Shows the next prayer time and countdown.
- Press Select to increment zikr.
- Press Back to mark the current prayer done.
- Hold/Menu opens reset options.

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
monkeyc -d fenixe -f monkey.jungle -o bin/SALAH.PRG -y keys/developer_key.der
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

The web app has the richer prayer calculation and settings. This Garmin app is a lightweight watch companion. The next improvement should be exact prayer calculation or syncing settings from the phone app.
