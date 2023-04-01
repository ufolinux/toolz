##
# Global variables for dialog
##

# Main dialog root
export D_ROOT=$P_ROOT/build/toolset/dialog

##
# Load modules for dialog extension
##

# Load package builder dialogs ( handles build/clean options )
source $D_ROOT/modules/package_builder.sh

##
# Main functions
##

dialog_main() {
    # clear shell
    clear

    # prompt dialog menu
    dialog_menu

    # clear up tmp
    clean_tmp

    # clear afterwards
    clear
}

dialog_menu() {
    # Option text
    OPTION1="Package Builder options"
    OPTION2="Build ISO"

    # Main function
    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30
    BACKTITLE=""
    TITLE="Developer's friendly UI"
    MENU="Choose one of the following options:"

    OPTIONS=(
        1 "${OPTION1}"
        2 "${OPTION2}"
        )

    CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

    case $CHOICE in
        1)
            echo "${OPTION1}"
            pkg_dialog_main
        ;;

        2)
            echo "${OPTION2}"
            dummy_dialog
        ;;
    esac
}

dummy_dialog() {
    clean_tmp

    clear
}
