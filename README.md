# Mi AI Button Remapper

A Magisk module that remaps the dedicated **Mi AI hardware button** of the
Xiaomi **Mi 9 (cepheus)** and **Mi Mix 3 (perseus)** to one of 16 remappable
functions (plus the stock AI behaviour on MIUI).

Modernized fork of [Cr0wTom/MiAI-remap](https://github.com/Cr0wTom/MiAI-remap)
(XDA thread: <https://forum.xda-developers.com/Mi-9/themes/mod-mi-ai-button-remapper-t3918291>).

**Status:** verified working on a Mi 9 (cepheus) with xiaomi.eu MIUI on
current Magisk.

## How it works

The module overlays `/system/usr/keylayout/gpio-keys.kl` with a patched copy
(the AI button is scan code `key 689`). No app, no daemon, no boot scripts -
just the file overlay.

1. Flash the zip **from the Magisk app** (recovery flashing is not supported).
2. Tap the **Action** button on the module card. Each tap cycles to the next
   function and prints the selection in the console.
3. **Reboot**. Done.

Note: if the **Action** button does not show up on the module card right
after installing, reboot once - it appears once the module list is refreshed
at boot.

Your selection survives module updates. To go back to the stock AI assistant,
cycle to *Stock AI button (MIUI)* (MIUI only) or simply disable/uninstall the
module and reboot.

### Scripted selection

Write a function name into a file and tap **Action** once to apply it directly
(the file is removed afterwards):

```sh
echo "SYSRQ" > /data/local/tmp/miai_choice
```

## Available functions

| Function | Keylayout label | Notes |
|---|---|---|
| Camera | `CAMERA` | |
| Screenshot | `SYSRQ` | |
| Google Search | `SEARCH` | |
| Voice Assistant | `VOICE_ASSIST` | Needs a configured default assistant app |
| Dialer | `CALL` | |
| Contacts | `CONTACTS` | App-launch key; needs ROM support |
| Music player | `MUSIC` | App-launch key; needs ROM support |
| Mute/unmute media | `VOLUME_MUTE` | |
| Play/pause media | `MEDIA_PLAY_PAUSE` | Works with the active media session |
| Next media track | `MEDIA_NEXT` | Works with the active media session |
| Recent apps | `APP_SWITCH` | |
| Notification shade / Quick Settings | `NOTIFICATION` | Replaces the old `QPANEL_ON_OFF` |
| Browser | `EXPLORER` | App-launch key; needs ROM support |
| Calendar | `CALENDAR` | App-launch key; needs ROM support |
| Calculator | `CALCULATOR` | App-launch key; needs ROM support |
| No function | `NONE` | Removes the key mapping entirely |
| Stock AI button (MIUI) | `AI` | MIUI only; not in the cycle on AOSP ROMs |

All labels are valid AOSP keylayout labels. Whether an app-launch key
(CONTACTS, MUSIC, ...) actually opens the app depends on the ROM - on MIUI
they work like in the original module. VOICE_ASSIST only does something if a
digital assistant app is configured as the default assistant.

## Troubleshooting

- **Remap has no effect after reboot:** the module overlays
  `/system/usr/keylayout/gpio-keys.kl`. On a Mi 9 with xiaomi.eu MIUI this
  was verified: the ROM reads the keylayout from `/system`, so the overlay
  works as-is and no vendor overlay is needed. Other ROMs may ship the file
  in the vendor partition (Android checks `/vendor` before `/system`);
  check with:

```sh
adb shell "ls -l /system/usr/keylayout/gpio-keys.kl /vendor/usr/keylayout/gpio-keys.kl"
```

  If the file exists in `/vendor`, please open an issue - the module then
  needs to overlay the vendor copy as well. The installer also prints a
  warning when it detects this situation.

- **A function does nothing:** some functions need a handler on the ROM side
  (see the "Notes" column above). Media keys (`MEDIA_PLAY_PAUSE`,
  `MEDIA_NEXT`) always work with the currently active media session.

## Building the zip

```sh
git clone https://github.com/Imacikus/MiAI-remap.git
cd MiAI-remap
zip -r9 ../XiaomiAI-remap-v1.0.4.zip module.prop customize.sh action.sh mai-common.sh system
```

### Automatic releases (CI)

Pushing a tag builds the zip on GitHub Actions and attaches it to a GitHub
release:

```sh
git tag v1.0.4 && git push origin v1.0.4
```

The tag must match the `version` in `module.prop`, otherwise the build
fails on purpose. The release contains exactly `module.prop`,
`customize.sh`, `action.sh`, `mai-common.sh` and `system/`.

### In-app updates

`module.prop` contains an `updateJson` pointing at
<https://github.com/Imacikus/MiAI-remap/releases/latest/download/update.json>.
Each release also ships a CI-generated `update.json` (`version`,
`versionCode`, `zipUrl`, `changelog`), so the Magisk app can notify about
and install updates in-app. The `changelog` URL points at
[CHANGELOG.md](CHANGELOG.md) at the release tag.

Note: this works from v1.0.3 onwards. Installations of v1.0.2 or older have
no `updateJson` yet and need one final manual update.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
