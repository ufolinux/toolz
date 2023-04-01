##
# Dialog extension for package builder ( Reuses existing shell module )
##

pkg_dialog_main() {
    # Option text
    OPTION1="Build package/packages"
    OPTION2="Build and clean package/packages"
    OPTION3="Clean package"

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
        3 "${OPTION3}"
        )

    CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                --erase-on-exit \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

    case $CHOICE in
        1)
            echo "${OPTION1}"
            dummy_dialog
        ;;

        2)
            echo "${OPTION2}"
            dummy_dialog
        ;;

        3)
            echo "${OPTION3}"
            dummy_dialog
        ;;
    esac
}
