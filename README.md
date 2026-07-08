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

## Install

For local testing, use Garmin Connect IQ simulator or Garmin's sideload/debug workflow for your watch model.

For sharing with friends, send the signed package at:

```text
bin/SalahCompanion.iq
```

See `INSTALL.md` for private sharing and manual installation notes.

## Notes

The web app has the richer prayer calculation and settings. This Garmin app is a lightweight watch companion. The next improvement should be exact prayer calculation or syncing settings from the phone app.
