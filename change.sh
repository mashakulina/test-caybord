#!/bin/bash

# if a password was set, this will run when the program closes
temp_pass_cleanup() {
  echo $PASS | sudo -S -k passwd -d deck
}

# removes unhelpful GTK warnings
zen_nospam() {
  zenity 2> >(grep -v 'Gtk' >&2) "$@"
}

# if the script is not root yet, get the password and rerun as root
if (( $EUID != 0 )); then
    PASS_STATUS=$(passwd -S deck 2> /dev/null)

    # get password
    while [ "$PASSWORD" != "true" ]; do
        PASS=$(zen_nospam --title="Adding a locale" --width=300 --height=100 --entry --hide-text --text="Enter your sudo/admin password")
    if ( echo "$PASS" | sudo -S -k true ); then
        PASSWORD="true"
    else
        zen_nospam --title="Adding a locale" --width=150 --height=40 --info --text "Incorrect Password"
    fi
  done
  echo "$PASS" | sudo -S -k bash "$0" "$@" # rerun script as root
  exit 1
fi

# if locale is already present in environment, then add 'recovery' option
if grep -q "XKB_DEFAULT_LAYOUT" /etc/environment ; then
    OPTION=$(zen_nospam --title="Adding a locale" --width=350 --height=200 --list --radiolist --text "The locale is already added\nSelect Option:" --hide-header --column "Buttons" --column "Choice"\
    TRUE "Recovery system file" \
    )
else
    OPTION=$(zen_nospam --title="Adding a locale" --width=350 --height=350 --list --radiolist --text "Select language to install:" --hide-header --column "Buttons" --column "Choice"\
    TRUE "Russian" \
    FALSE "German" \
    FALSE "French" \
    FALSE "Spanish" \
    FALSE "Spanish (Mexico)" \
    FALSE "Italian" \
    FALSE "Portuguese" \
    FALSE "Portuguese (Brazil)" \
    FALSE "Chinese" \
    FALSE "Japanese"
    )
fi

# Recovery system file if recovery option was selected
if [ "$OPTION" == "Recovery system file" ] ; then
    (
    echo "Delete old Environment...";
    sudo rm /etc/environment
    echo "Environment recovery from bakup...";
    sudo mv /etc/environment.bak /etc/environment

    # Reboot/Later
    OPTION=$(zen_nospam --title="Adding a locale" --width=350 --height=100 --list --radiolist --text "Reboot system:" --hide-header --column "Buttons" --column "Choice"\
    TRUE "Reboot now" \
    FALSE "Reboot later")

    # Reboot later
    if [ "$OPTION" == "Reboot later" ]; then
        zen_nospam --title="Adding a locale" --width=150 --height=40 --info --text "Don't forget to reboot your system later"
        exit 0
    else
    # Reboot after recovery
        echo "Reboot!"
        shutdown now -r
    fi
  )
fi

if [[ "$OPTION" == "Russian" ]]; then
  (
  echo "Backup environment..."
  sudo cp /etc/environment /etc/environment.bak
  
  # Select layout
if  OPTION=$(zen_nospam --title="Layout switching option" --width=350 --height=350 --list --radiolist --text "Select the option to switch the layout:" --hide-header --column "Buttons" --column "Choice"\
    TRUE "shift+ctrl" \
    FALSE "shift+alt" \
    )
fi  
  if [[ "$OPTION" == "shift+ctrl" ]]; then
  # Select shift+ctrl
  echo "Adding parameter in environment..."
  sudo sed -i '5 a\XKB_DEFAULT_LAYOUT=ru,us\nXKB_DEFAULT_OPTIONS=grp:lctrl_lshift_toggle\n' /etc/environment
  else
  # Select shift+alt
  echo "Adding parameter in environment..."
  sudo sed -i '5 a\XKB_DEFAULT_LAYOUT=ru,us\nXKB_DEFAULT_OPTIONS=grp:lalt_lshift_toggle\n' /etc/environment
  
  # Reboot/Later
  if grep -q "XKB_DEFAULT_LAYOUT" /etc/environment ; then
      OPTION=$(zen_nospam --title="Adding a locale" --width=350 --height=100 --list --radiolist --text "Reboot system:" --hide-header --column "Buttons" --column "Choice"\
      TRUE "Reboot now" \
      FALSE "Reboot later"
      )
  fi
    # Reboot later
    if [ "$OPTION" == "Reboot later" ]; then
        zen_nospam --title="Adding a locale" --width=150 --height=40 --info --text "Don't forget to reboot your system later"
        exit 0
    else
    # Reboot after recovery
        echo "Reboot!"
        shutdown now -r
    fi
  )
fi

fi
