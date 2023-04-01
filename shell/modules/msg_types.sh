##
#   Colors for msg functions to use
##

RED='\033[0;31m'
LRED='\033[1;31m'

ORANGE='\033[0;33m'
YELLOW='\033[1;33m'

GREEN='\033[0;32m'
LGREEN='\033[1;32m'

BLUE='\033[0;34m'
LBLUE='\033[1;34m'

WHITE='\033[1;37m'

##
#   msg functions
##

message() {
    echo -e "${GREEN}[ MESSAGE ]: ${LGREEN}$@${WHITE}"
}

msg_warning() {
    echo -e "${ORANGE}[ WARNING ]: ${YELLOW}$@${WHITE}"
}

msg_error() {
    echo -e "${RED}[ ERROR ]: ${LRED}$@${WHITE}"
    exit 1
}

msg_fault() {
    echo -e "${RED}[ FAULT ]: ${LRED}$@${WHITE}"
}

msg_spacer() {
    echo " "
    echo -e ${GREEN}------------------${WHITE}
    echo " "
}

##
# DEBUG LOGS
##
if [ "$SHOW_DEBUG" = "true" ]; then
    msg_debug() {
        echo -e "${BLUE}[ DEBUG ]: ${LBLUE}$@${WHITE}"
    }
else
    msg_debug() {
        test 0
    }
fi
