#!/system/bin/sh
###############################################################################
# Xiaomi AI Button Remapper - mai-common.sh
#
# Shared helpers, sourced by customize.sh (installer) and action.sh
# (Magisk app "Action" button). Kept in one place so both stay in sync.
###############################################################################

# Selectable functions (valid AOSP keylayout labels). 'AI' is MIUI-only and
# 'NONE' removes the key line entirely, so neither is part of this list.
FUNCTIONS="CAMERA SYSRQ SEARCH VOICE_ASSIST CALL CONTACTS MUSIC VOLUME_MUTE MEDIA_PLAY_PAUSE MEDIA_NEXT APP_SWITCH NOTIFICATION EXPLORER CALENDAR CALCULATOR"

is_miui() {
  [ -n "$(getprop ro.miui.ui.version.code)" ] || [ -n "$(getprop ro.miui.version)" ]
}

# $1 is a valid selectable label (FUNCTIONS + NONE + AI on MIUI)
is_choice() {
  case " $FUNCTIONS NONE " in *" $1 "*) return 0 ;; esac
  [ "$1" = "AI" ] && is_miui && return 0
  return 1
}

# Full cycle order: functions, then stock AI (MIUI only), then NONE last.
cycle_list() {
  if is_miui; then
    echo "$FUNCTIONS AI NONE"
  else
    echo "$FUNCTIONS NONE"
  fi
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

# apply_label <keylayout-file> <label>
apply_label() {
  _kl="$1"; _label="$2"
  if [ "$_label" = "NONE" ]; then
    sed -i '/^key 689[[:space:]]/d' "$_kl"
  elif grep -q '^key 689[[:space:]]' "$_kl"; then
    sed -i -E "s/^key 689.*/key 689   $_label/" "$_kl"
  else
    printf 'key 689   %s\n' "$_label" >> "$_kl"
  fi
  # sed -i rewrites the file, so keep the mode sane afterwards
  chmod 0644 "$_kl" 2>/dev/null
  return 0
}
