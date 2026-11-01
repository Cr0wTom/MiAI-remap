# Changelog

## 2026-11-01: v1.0.4

- The installer output now mentions that the "Action" button may only show
  up on the module card after a reboot (the Magisk app refreshes the module
  list at boot). Confirmed on-device on a Mi 9.
- README: same hint added to "How it works"; VOICE_ASSIST is now marked as
  depending on a configured default assistant app (with e.g. Home Assistant
  set as assistant, the keycode may not be handled by anything).

## 2026-11-01: v1.0.3

- `module.prop` now contains an `updateJson` pointing at
  <https://github.com/Imacikus/MiAI-remap/releases/latest/download/update.json>.
  CI generates an `update.json` (`version`, `versionCode`, `zipUrl`,
  `changelog`) per release, so the Magisk app can notify about and install
  updates in-app.
- Changelog moved from README.md into this file; the Magisk update dialog
  displays this file for new versions.
- Note for existing installations: `updateJson` only works from this version
  onwards - installs of v1.0.2 or older have no `updateJson` yet and need one
  final manual update.

## 2026-11-01: v1.0.2

- `action.sh`: a stale `AI` entry in the config (from an earlier MIUI
  install) is now normalized to `NONE` on AOSP-based ROMs, so the
  "Previous" output stays accurate.
- CI: added `.github/workflows/release.yml` - pushing a `v*` tag builds the
  flashable zip (with `sh -n` validation and a tag/`module.prop` version
  check) and attaches it to a GitHub release.

## 2026-11-01: v1.0.1 - review fixes

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

## 2026-11-01: v1.0.0 - modernized fork

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

## 2019-04-18: v0.4 (upstream, Cr0wTom)

- No double tap (it cannot actually work - no mapping equivalent)
- Device checking addition
- "No function" (disable of button) addition

## 2019-04-06: v0.3

- Fix for double selecting problem

## 2019-04-05: v0.2

- Fix of some residues of the old repo

## 2019-04-04: v0.1

- Initial release
