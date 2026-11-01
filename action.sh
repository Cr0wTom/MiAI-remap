#!/system/bin/sh
###############################################################################
# Xiaomi AI Button Remapper - action.sh
#
# Runs when you tap the "Action" button on the module card in the Magisk app.
# Every tap cycles to the next function and rewrites the keylayout file.
# Reboot to apply the new mapping.
#
# Scripted usage: write a function name (see mai-common.sh) into
# /data/local/tmp/miai_choice and tap "Action" once - it is then applied
# directly and the file is removed.
###############################################################################

MODDIR=${0%/*}
CFG="$MODDIR/config"
CHOICE_FILE="/data/local/tmp/miai_choice"

[ -f "$MODDIR/mai-common.sh" ] || { echo "! helper missing: $MODDIR/mai-common.sh"; exit 1; }
. "$MODDIR/mai-common.sh"

KL="$MODDIR/system/usr/keylayout/gpio-keys.kl"
[ -f "$KL" ] || { echo "! keylayout file missing: $KL"; exit 1; }

current=$(head -n1 "$CFG" 2>/dev/null | tr -d '[:space:]')
[ -n "$current" ] || current=NONE

target=""

# Direct selection via config file (for automation / remote shells)
if [ -f "$CHOICE_FILE" ]; then
  req=$(head -n1 "$CHOICE_FILE" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
  if is_choice "$req"; then
    target="$req"
    rm -f "$CHOICE_FILE"
  else
    echo "! '$req' is not a valid function. Valid: $(cycle_list)"
    exit 1
  fi
fi

# Otherwise cycle to the next function
# (order: functions, then stock AI on MIUI, then NONE last, then wrap around)
if [ -z "$target" ]; then
  target=$(cycle_list | awk -v cur="$current" '{
    n = split($0, a, " ")
    for (i = 1; i <= n; i++) {
      if (a[i] == cur) { print a[(i % n) + 1]; exit }
    }
    print a[1]
  }')
fi

apply_label "$KL" "$target"
echo "$target" > "$CFG"
chmod 0644 "$CFG" 2>/dev/null

echo "**********************************"
echo "  Xiaomi AI Button Remapper"
echo "**********************************"
echo "  Previous: $(desc "$current")"
echo "  AI button now maps to: $(desc "$target") [$target]"
echo ""
echo "  Tap 'Action' again for the next function."
echo "  Reboot to apply."
