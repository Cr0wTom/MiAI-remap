#!/system/bin/sh
###############################################################################
# Xiaomi AI Button Remapper - action.sh
#
# Runs when you tap the "Action" button on the module card in the Magisk app.
# Every tap cycles to the next function and rewrites the keylayout file.
# Reboot to apply the new mapping.
#
# Scripted usage: write a function name (see list below) into
# /data/local/tmp/miai_choice and tap "Action" once - it is then applied
# directly and the file is removed.
###############################################################################

MODDIR=${0%/*}
KL="$MODDIR/system/usr/keylayout/gpio-keys.kl"
CFG="$MODDIR/config"
CHOICE_FILE="/data/local/tmp/miai_choice"

CHOICES="CAMERA SYSRQ SEARCH VOICE_ASSIST CALL CONTACTS MUSIC VOLUME_MUTE MEDIA_PLAY_PAUSE MEDIA_NEXT APP_SWITCH NOTIFICATION EXPLORER CALENDAR CALCULATOR NONE"

is_miui() {
  [ -n "$(getprop ro.miui.ui.version.code)" ] || [ -n "$(getprop ro.miui.version)" ]
}

is_choice() {
  case " $CHOICES " in *" $1 "*) return 0 ;; esac
  return 1
}

desc() {
  case "$1" in
    CAMERA)           echo "Camera" ;;
    SYSRQ)            echo "Screenshot" ;;
    SEARCH)           echo "Google Search" ;;
    VOICE_ASSIST)     echo "Voice Assistant" ;;
    CALL)             echo "Dialer" ;;
    CONTACTS)         echo "Contacts" ;;
    MUSIC)            echo "Music player" ;;
    VOLUME_MUTE)      echo "Mute/unmute media volume" ;;
    MEDIA_PLAY_PAUSE) echo "Play/pause media" ;;
    MEDIA_NEXT)       echo "Next media track" ;;
    APP_SWITCH)       echo "Recent apps" ;;
    NOTIFICATION)     echo "Notification shade / Quick Settings" ;;
    EXPLORER)         echo "Browser" ;;
    CALENDAR)         echo "Calendar" ;;
    CALCULATOR)       echo "Calculator" ;;
    NONE)             echo "Disabled (no function)" ;;
    AI)               echo "Stock AI button (MIUI)" ;;
    *)                echo "$1" ;;
  esac
}

apply_label() {
  if [ "$1" = "NONE" ]; then
    sed -i '/^key 689[[:space:]]/d' "$KL"
  elif grep -q '^key 689[[:space:]]' "$KL"; then
    sed -i -E "s/^key 689.*/key 689   $1/" "$KL"
  else
    printf 'key 689   %s\n' "$1" >> "$KL"
  fi
}

[ -f "$KL" ] || { echo "! keylayout file missing: $KL"; exit 1; }

current=$(head -n1 "$CFG" 2>/dev/null | tr -d '[:space:]')
[ -n "$current" ] || current=NONE

# 'AI' is only a valid label on MIUI; on other ROMs start over.
if [ "$current" = "AI" ] && ! is_miui; then
  current=NONE
fi

target=""

# Direct selection via config file (for automation / remote shells)
if [ -f "$CHOICE_FILE" ]; then
  req=$(head -n1 "$CHOICE_FILE" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
  if is_choice "$req" || { [ "$req" = "AI" ] && is_miui; }; then
    target="$req"
    rm -f "$CHOICE_FILE"
  else
    echo "! '$req' is not a valid function. Valid: $CHOICES AI"
    exit 1
  fi
fi

# Otherwise cycle to the next function
if [ -z "$target" ]; then
  list="$CHOICES AI"
  is_miui || list="$CHOICES"
  target=$(echo $list | awk -v cur="$current" '{
    n = split($0, a, " ")
    for (i = 1; i <= n; i++) {
      if (a[i] == cur) { print a[(i % n) + 1]; exit }
    }
    print a[1]
  }')
fi

apply_label "$target"
echo "$target" > "$CFG"

echo "**********************************"
echo "  Xiaomi AI Button Remapper"
echo "**********************************"
echo "  Previous: $(desc "$current")"
echo "  AI button now maps to: $(desc "$target") [$target]"
echo ""
echo "  Tap 'Action' again for the next function."
echo "  Reboot to apply."
