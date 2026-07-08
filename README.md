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

Final app file path:

```text
bin/SalahCompanion-fenixe.prg
```

Garmin Express can detect the watch, but it does not sideload local `.prg` or `.iq` files. For a local physical install, use File Transfer / MTP and copy the compiled `.prg` to the watch.

1. Unlock the Garmin watch.
2. Connect it to the Mac via USB.
3. Choose File Transfer / MTP mode on the watch if prompted.
4. Build the app for the exact device target:

```bash
monkeyc -d fenixe -f monkey.jungle -o bin/SalahCompanion-fenixe.prg -y keys/developer_key.der
```

5. Use MTP/File Transfer to upload:

```text
bin/SalahCompanion-fenixe.prg
```

to:

```text
GARMIN/Apps/
```

6. Unplug the watch.
7. Wait 10-20 seconds.
8. Open the watch app list and launch Salah Companion.
9. If it does not appear, restart the watch.

Troubleshooting:

- If `/Volumes/GARMIN` does not appear on macOS, use MTP instead.
- `monkeydo` and `mdd` are simulator/debug tools, not physical deployment tools.
- Garmin Express detects the watch but does not provide local sideload.
- ADB is not applicable.
- The watch must be unlocked before MTP access works.

## Install

For local testing, use Garmin Connect IQ simulator or Garmin's sideload/debug workflow for your watch model.

For sharing with friends, send the signed package at:

```text
bin/SalahCompanion.iq
```

See `INSTALL.md` for private sharing and manual installation notes.

## Notes

The web app has the richer prayer calculation and settings. This Garmin app is a lightweight watch companion. The next improvement should be exact prayer calculation or syncing settings from the phone app.
