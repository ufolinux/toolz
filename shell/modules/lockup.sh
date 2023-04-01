check_and_setup_lock() {
    IS_COMPILING=none

    # Lets allow devs to bypass the lockup if variable is given
    if [ "${IGNORE_LOCKUP}" = "yes" ]; then
        rm -f $TOOL_TEMP/.builder_locked
        rm -f $TOOL_TEMP/builds
    fi

    # Check wheather system has a lock on it or not
    if [ -f $TOOL_TEMP/.builder_locked ]; then
        if [ -f $TOOL_TEMP/builds ]; then
            source $TOOL_TEMP/builds
            msg_warning Something is still compiling under background...
            msg_error And that pkg name is: $IS_COMPILING
        else
            msg_warning Something is still compiling under background...

            show_tmp_status

            msg_error As we cant reach tmp files for proper specifications we just error out
        fi
    else
        # Lock the build system
        lock_drunk
    fi
}

show_tmp_status() {
    msg_spacer
    message "These are the results of known files to lockup the builder"
    echo " "
    msg_warning "File listing in tmp*"
    ls -a $TOOL_TEMP/
    echo " "
    msg_warning "Results of tmp/*"
    for f in $TOOL_TEMP/* ; do
        msg_warning "${f} : $(cat ${f})"
    done

    msg_spacer
}

lock_drunk() {
    if [ "${IGNORE_LOCKUP}" = "yes" ]; then
        rm -f $TOOL_TEMP/.builder_locked
    else
        touch $TOOL_TEMP/.builder_locked
    fi
}
