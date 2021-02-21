##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
# 
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print "    Xiaomi AI key remapper     "
  ui_print "*******************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  #Place for check functions
  device_check

  ui_print "- Configuring Xiaomi AI button..."
  ui_print "Single tap configuration"
  ui_print ""
  ui_print "Make a choice from the following functions:"
  ui_print ""
  ui_print "Camera (CAMERA)"
  ui_print "Screenshot (SYSRQ)"
  ui_print "Google Search (SEARCH)"
  ui_print "Google Voice (VOICE_ASSIST)"
  ui_print "Call (CALL)"
  ui_print "Contacts (CONTACTS)"
  ui_print "Music Player (MUSIC)"
  ui_print "Mute/Unmute Media Volume (VOLUME_MUTE)"
  ui_print "Wake phone (POWER)"
  ui_print "Play/Pause Media (MEDIA_PLAY_PAUSE)"
  ui_print "Next Media (MEDIA_NEXT)"
  ui_print "Recent Apps (APP_SWITCH)"
  ui_print "Open/Close Quick Settings (QPANEL_ON_OFF)"
  ui_print "Internet Browser (EXPLORER)"
  ui_print "Calendar (CALENDAR)"
  ui_print "Calculator (CALCULATOR)"
  ui_print "No Function (NOF)"
  ui_print ""
  ui_print "Use the hardware buttons to make a selection."
  ui_print ""
  
  q_and_a CAMERA SYSRQ Other
  q_and_a 
  [ -z "$CHOICE" ] && q_and_a SEARCH VOICE_ASSIST Other
  q_and_a 
  [ -z "$CHOICE" ] && q_and_a CALL CONTACTS Other
  q_and_a 
  [ -z "$CHOICE" ] && q_and_a MUSIC VOLUME_MUTE Other
  q_and_a
  [ -z "$CHOICE" ] && q_and_a POWER VOLUME_MUTE Other
  q_and_a 
  [ -z "$CHOICE" ] && q_and_a MEDIA_PLAY_PAUSE MEDIA_NEXT Other
  q_and_a 
  [ -z "$CHOICE" ] && q_and_a APP_SWITCH QPANEL_ON_OFF Other
  q_and_a 
  [ -z "$CHOICE" ] && q_and_a EXPLORER CALENDAR Other
  q_and_a 
  [ -z "$CHOICE" ] && q_and_a CALCULATOR NOF Other
  q_and_a 
  if [ -z "$CHOICE" ]; then
    ui_print "- No choice made. Using CAMERA."
    CHOICE=CAMERA
  fi
  
  kl=/system/usr/keylayout/gpio-keys.kl
  
  sed -i -re 's/(key 689 +)[A-Z]+$/\1'$CHOICE'/' $MODPATH$kl

}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code

get_key() {
  local key=$( /system/bin/getevent -lqc 1  | awk '{ print $(NF-1) }' )
  [ $key = 02b1 ] && key=KEY_AI

  echo $key
}

q_and_a() {
  if [ -z "$1" ]; then
    local a=$(get_key)
    return 0
  fi
  local choice1="     [Vol Up]   = $1"
  local choice2="     [Vol Down] = $2"
  local choice3="     [AI]    = $3"

  ui_print "- Which function?"
  ui_print "$choice1"
  ui_print "$choice2"
  [ -n "$3" ] && ui_print "$choice3"

  local n=99
  until [ $n -le $# ]; do
    unset UP DOWN AI
    local a=$(get_key)

    case $a in
      *UP)
        UP=true
        n=1
        ;;
      *DOWN)
        DOWN=true
        n=2
        ;;
      *AI)
        AI=true
        n=3
        ;;
      *)
	      n=99
        ;;
    esac

  done

  CHOICE=$(eval echo '$'$n)
  ui_print ""
  [ $CHOICE = Other ] && unset CHOICE
}


device_check() {
  bl=$(getprop ro.product.name)
  device=${bl:0:7}
  if ( [ $device = cepheus ] || [ $device = perseus ]); then
    break
  else
    abort "Unsupported device or modified build.prop"
  fi

}
