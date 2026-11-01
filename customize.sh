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

KL="$MODPATH/system/usr/keylayout/gpio-keys.kl"
[ -f "$KL" ] || abort "! Module file missing: system/usr/keylayout/gpio-keys.kl"

# --- Device check -------------------------------------------------------------
# Mi 9 = cepheus, Mi Mix 3 = perseus. Also accept ro.product.device because
# custom ROMs often change ro.product.name (the old module aborted wrongly).

DEV=$(getprop ro.product.device)
NAME=$(getprop ro.product.name)
case " $DEV $NAME " in
  *cepheus*|*perseus*) ;;
  *) abort "! Unsupported device (device='$DEV' name='$NAME'). Only Xiaomi Mi 9 (cepheus) and Mi Mix 3 (perseus) are supported." ;;
esac

# --- Keylayout labels ---------------------------------------------------------
# Valid AOSP keylayout labels only. The old module used 'NOF' and
# 'QPANEL_ON_OFF', which are NOT valid labels: one invalid line makes Android
# discard the ENTIRE keylayout file (volume keys would lose their mapping).
# "AI" is a MIUI-only label, so it is only ever written on MIUI.

CHOICES="CAMERA SYSRQ SEARCH VOICE_ASSIST CALL CONTACTS MUSIC VOLUME_MUTE MEDIA_PLAY_PAUSE MEDIA_NEXT APP_SWITCH NOTIFICATION EXPLORER CALENDAR CALCULATOR NONE"

is_choice() {
  case " $CHOICES " in *" $1 "*) return 0 ;; esac
  return 1
}

apply_label() {
  # $1 = keylayout label; NONE removes the key line entirely (real "no function")
  if [ "$1" = "NONE" ]; then
    sed -i '/^key 689[[:space:]]/d' "$KL"
  elif grep -q '^key 689[[:space:]]' "$KL"; then
    sed -i -E "s/^key 689.*/key 689   $1/" "$KL"
  else
    printf 'key 689   %s\n' "$1" >> "$KL"
  fi
}

# --- ROM check -----------------------------------------------------------------

IS_MIUI=false
if [ -n "$(getprop ro.miui.ui.version.code)" ] || [ -n "$(getprop ro.miui.version)" ]; then
  IS_MIUI=true
fi

# --- Choose the initial mapping ------------------------------------------------
# Keep the user's previous selection when updating the module. Otherwise keep
# the stock MIUI behaviour on MIUI, and disable the key on AOSP-based ROMs
# (where the MIUI-only 'AI' label would invalidate the whole file).

CFG="$MODPATH/config"
LABEL=""
if [ -f /data/adb/modules/XiaomiAI-remap/config ]; then
  LABEL=$(head -n1 /data/adb/modules/XiaomiAI-remap/config | tr -d '[:space:]')
fi

if [ -n "$LABEL" ] && is_choice "$LABEL"; then
  ui_print "- Keeping previous function: $LABEL"
elif [ -n "$LABEL" ] && [ "$LABEL" = "AI" ] && $IS_MIUI; then
  ui_print "- Keeping previous function: stock AI button"
elif $IS_MIUI; then
  LABEL=AI
  ui_print "- MIUI detected: AI button keeps stock behaviour for now"
else
  LABEL=NONE
  ui_print "- AOSP-based ROM detected: AI button stays disabled for now"
  ui_print "  (the 'AI' keycode only exists on MIUI)"
fi

apply_label "$LABEL"
echo "$LABEL" > "$CFG"

ui_print ""
ui_print "- Installed. Tap 'Action' on the module card in the Magisk app"
ui_print "  to cycle through the available functions, then reboot to apply."
