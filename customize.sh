#!/system/bin/sh
###############################################################################
# Xiaomi AI Button Remapper - customize.sh
#
# Modern Magisk module installer script (sourced by Magisk's own installer).
# There is deliberately NO interactive key selection here: on current Magisk
# versions that mechanism (getevent in the installer) is unreliable.
#
# Workflow: install via the Magisk app, then tap the "Action" button on the
# module card to cycle through the functions (see action.sh), then reboot.
###############################################################################

# The Magisk app is the only supported installation method for this module.
if ! $BOOTMODE; then
  abort "! Please install this module from the Magisk app (recovery flashing is not supported)"
fi

# Module id straight from the install path - nothing hardcoded.
MODID=${MODPATH##*/}
KL="$MODPATH/system/usr/keylayout/gpio-keys.kl"
[ -f "$KL" ] || abort "! Module file missing: system/usr/keylayout/gpio-keys.kl"

# Extract and load the shared helpers (action.sh needs them at runtime too)
unzip -o "$ZIPFILE" mai-common.sh -d "$MODPATH" >&2
[ -f "$MODPATH/mai-common.sh" ] || abort "! Module file missing: mai-common.sh"
. "$MODPATH/mai-common.sh"

# --- Device check -------------------------------------------------------------
# Mi 9 = cepheus, Mi Mix 3 = perseus. Accept the codename in both
# ro.product.device and ro.product.name (custom ROMs often change the latter).

DEV=$(getprop ro.product.device)
NAME=$(getprop ro.product.name)
case " $DEV $NAME " in
  *cepheus*|*perseus*) ;;
  *) abort "! Unsupported device (device='$DEV' name='$NAME'). Only Xiaomi Mi 9 (cepheus) and Mi Mix 3 (perseus) are supported." ;;
esac

# --- Keylayout location check -------------------------------------------------
# Android reads keylayouts from /vendor before /system. If this ROM ships the
# file in /vendor, our /system overlay would be ignored.

if [ -f /vendor/usr/keylayout/gpio-keys.kl ]; then
  ui_print "! WARNING: /vendor/usr/keylayout/gpio-keys.kl exists on this ROM."
  ui_print "  Android reads /vendor BEFORE /system, so this module's"
  ui_print "  override may not take effect. Please report your ROM here:"
  ui_print "  https://github.com/Imacikus/MiAI-remap/issues"
fi

# --- Pick the initial mapping ---------------------------------------------------
# Keep the user's previous selection when updating the module. Otherwise keep
# the stock MIUI behaviour on MIUI, and disable the key on AOSP-based ROMs
# (where the MIUI-only 'AI' label would invalidate the whole file).

CFG="$MODPATH/config"
LABEL=""
if [ -f "/data/adb/modules/$MODID/config" ]; then
  LABEL=$(head -n1 "/data/adb/modules/$MODID/config" | tr -d '[:space:]')
fi

if [ -n "$LABEL" ] && is_choice "$LABEL"; then
  ui_print "- Keeping previous function: $LABEL"
else
  if is_miui; then
    LABEL=AI
    ui_print "- MIUI detected: AI button keeps stock behaviour for now"
  else
    LABEL=NONE
    ui_print "- AOSP-based ROM detected: AI button stays disabled for now"
    ui_print "  (the 'AI' keycode only exists on MIUI)"
  fi
fi

apply_label "$KL" "$LABEL"
echo "$LABEL" > "$CFG"

# --- Permissions -----------------------------------------------------------------
# sed -i rewrote $KL, so (re)set permissions explicitly. Also make the runtime
# scripts executable regardless of the git file mode (the GitHub API stores
# them as 0644; Magisk runs action.sh via sh, but 0755 is the safe default).

set_perm "$KL" 0 0 0644
set_perm "$CFG" 0 0 0644
set_perm "$MODPATH/mai-common.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755

ui_print ""
ui_print "- Installed. Tap 'Action' on the module card in the Magisk app"
ui_print "  to cycle through the available functions, then reboot to apply."
