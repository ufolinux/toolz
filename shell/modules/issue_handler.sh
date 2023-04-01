interrupt_handle() {
    clean_tmp
    msg_warning POSSIBLE CRASH/ERROR CAUSED BY CTRL+C / INTERRUPT
    sleep 1

    exit
}

exit_handle() {
    clean_tmp
    msg_debug $?
    msg_warning SCRIPT EXITED

    exit
}

# Untils logging issue is fixed
tmp_err_handle() {
    msg_warning Script had a error so we need to exit by cleaning tmp files
    clean_tmp
    msg_error Bye
}

err_handle() {
    # Post error message with cathered log
    fault_log=$( tail "$TOOL_TEMP/msg_error.log" )

    msg_spacer
    msg_fault $fault_log
    msg_spacer

    cp $TOOL_TEMP/msg_error.log $P_ROOT/build_error.log
    clean_tmp
    sleep 2

    exit
}

start_logging() {
    # Setup logging
    local err_code="${1:-$?}"

    touch $TOOL_TEMP/msg_error.log
    declare err_log=$TOOL_TEMP/msg_error.log

    # Log error messages
    #exec 2> $err_log
    exec 2> $err_log
    exec 3>&-
}
