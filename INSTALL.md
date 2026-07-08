# Installing Salah Companion on Garmin

## File to share

Send this final signed Connect IQ package to friends:

```text
bin/SalahCompanion.iq
```

## Private sharing options

You can send the `.iq` file privately using:

- WhatsApp
- Telegram
- Email
- Google Drive
- AirDrop

## Installation note

Friends can receive the `.iq` file, but receiving the file is not the same as installing it on a real Garmin watch. Newer watches such as the Garmin fēnix E may reject or ignore manual local sideload files even when the file is copied successfully.

Recommended private beta testing flow:

1. Confirm the tester's watch is paired and syncing in Garmin Connect.
2. Upload `bin/SalahCompanion.iq` to the Garmin Connect IQ developer portal.
3. Create a private beta or unpublished test listing.
4. Add the tester's Garmin account.
5. Have the tester install Salah Companion through the Connect IQ app/store flow.
6. Sync the watch.
7. Open the watch app list and launch Salah Companion.

Manual PRG sideload is only a troubleshooting path:

```text
bin/SALAH.PRG -> GARMIN/Apps/SALAH.PRG
```

If the PRG is visible over MTP but the app does not appear after unplugging and restarting the watch, use the Connect IQ private beta route instead.

## iPhone note

For iPhone users, WhatsApp, Telegram, AirDrop, Email, or Google Drive are fine for sending the file. Installation on the actual Garmin watch should use the Connect IQ app/private beta flow when the watch is paired to Garmin Connect.

## Recommendation

For easier sharing with many users, use a Garmin Connect IQ private beta. A private beta or store listing is the cleanest path for non-technical testers because Garmin handles device compatibility and installation through the official Connect IQ flow.
