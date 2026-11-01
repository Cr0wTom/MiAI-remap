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
| Voice Assistant | `VOICE_ASSIST` | |
| Dialer | `CALL` | |
| Contacts | `CONTACTS` | App-launch key; needs ROM support |
| Music player | `MUSIC` | App-launch key; needs ROM support |
| Mute/unmute media | `VOLUME_MUTE` | |
| Play/pause media | `MEDIA_PLAY_PAUSE` | |
| Next media track | `MEDIA_NEXT` | |
| Recent apps | `APP_SWITCH` | |
| Notification shade / Quick Settings | `NOTIFICATION` | Replaces the old `QPANEL_ON_OFF` |
| Browser | `EXPLORER` | App-launch key; needs ROM support |
| Calendar | `CALENDAR` | App-launch key; needs ROM support |
| Calculator | `CALCULATOR` | App-launch key; needs ROM support |
| No function | `NONE` | Removes the key mapping entirely |
| Stock AI button (MIUI) | `AI` | MIUI only; not in the cycle on AOSP ROMs |

All labels are valid AOSP keylayout labels. Whether an app-launch key
(CONTACTS, MUSIC, ...) actually opens the app depends on the ROM - on MIUI
they work like in the original module.

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

## Building the zip

```sh
git clone https://github.com/Imacikus/MiAI-remap.git
cd MiAI-remap
zip -r9 ../XiaomiAI-remap-v1.0.1.zip module.prop customize.sh action.sh mai-common.sh system
```

## Changelog

**2026-11-01: v1.0.1** - review fixes

- Shared logic (`FUNCTIONS`, `desc`, `apply_label`, MIUI check) moved into
  `mai-common.sh`; `customize.sh` and `action.sh` source it, so the two can
  no longer drift apart.
- The keylayout is now shipped **without** the `key 689` line; the installer
  adds the proper mapping. The shipped file is therefore valid even if
  `customize.sh` is ever skipped (the MIUI-only `AI` label used to make the
  whole file unparseable on AOSP ROMs).
- Module id is derived from `$MODPATH` instead of being hardcoded.
- Cycle order fixed: stock AI now comes **before** "No function";
  `NONE` is always the last state (wrap-around goes to `CAMERA`).
- Permissions are re-applied after `sed -i` rewrites the keylayout, and
  `action.sh`/`mai-common.sh` are made executable at install time
  (the GitHub API stores them as 0644).
- The installer warns when `/vendor/usr/keylayout/gpio-keys.kl` exists, since
  Android reads keylayouts from `/vendor` before `/system`.
- Verified on a real Mi 9 (xiaomi.eu MIUI): the keylayout lives in `/system`,
  so the module's overlay approach is correct for this ROM and no vendor
  overlay is needed.

**2026-11-01: v1.0.0** - modernized fork

- Rewritten for current Magisk: the old `install.sh` is ignored by Magisk 20+
  (the module installed silently with the stock mapping, which is why the
  function selection "did not work at all" on modern Magisk). Installation now
  uses `customize.sh` and is non-interactive.
- Function selection moved to the Magisk app **Action** button (`action.sh`):
  no more unreliable `getevent` volume-key detection in the installer.
- Fixed "No function": `NOF` is not a valid keylayout label; one invalid line
  makes Android discard the *entire* `gpio-keys.kl`. The key line is now
  removed properly.
- Removed `QPANEL_ON_OFF` (also not a valid AOSP label) and replaced it with
  `NOTIFICATION`.
- Device check now also accepts `ro.product.device` (custom ROMs often
  change `ro.product.name`) and no longer uses `break` outside a loop.
- The selection survives module updates; scripted selection via
  `/data/local/tmp/miai_choice`.
- Removed unused placeholder boot scripts and recovery (`META-INF`) support.

**2019-04-18: v0.4** (upstream, Cr0wTom)

- No double tap (it cannot actually work - no mapping equivalent)
- Device checking addition
- "No function" (disable of button) addition

**2019-04-06: v0.3** - Fix for double selecting problem
**2019-04-05: v0.2** - Fix of some residues of the old repo
**2019-04-04: v0.1** - Initial release
