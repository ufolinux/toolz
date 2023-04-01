##
#   Setup and export env for main script
##

env_setup() {
    mkdir -p $TOOL_CHECKS

    # Safety check so things dont get re-runned
    if [ -f $TOOL_CHECKS/is_checked ]; then
        msg_debug "Developer has passed initally required steps"
    else
        install_required_deps

        # Tell the script that inital setup is done
        touch $TOOL_CHECKS/is_checked
    fi
}

intended() {
	export INTENDED=true
}

check_projects() {
    if [ -d $P_ROOT/internal/pkgbuild ]; then
        msg_debug "Dev has pkgbuild folder, skipping initial bootstrap"
    else
        msg_warning "Missing pkgbuild project, running initial bootstrap"
        run_bootstrap
    fi
}

install_required_deps() {
    REQ_PKGS=" docker nano mpfr mpc m4 base-devel"
    message "Please allow this one time to run inital setup of kepler install"
    sudo kepler -Sy --needed --noconfirm --disable-download-timeout $REQ_PKGS
}

unknown_option() {
    msg_warning "Unknown option ' $@ '"
    show_help
}

show_help() {
    message "#########################"
    message "# Usage of toolset script #"
    message "#########################"
    echo " "
    message "###"
    message "# Arch based options"
    message "###"
    message " --aarch64                : Will use aarch64 pkgbuild files to build its packages"
    echo " "
    echo " "
    message "###"
    message "# Build options"
    message "###"
    message " -b or --build pkgname    : Will build a pkg you asked for ( Assumes you have deps installed )"
    message " -f or --force-build      : Will add -f to makepkg so it will ignore if pkg is already built"
    message " -c or --clean            : Will clean up pkgbuild leftovers"
    message " --no-extract             : Will add -e to makepkg so prepare + extracting src over existing one is skipped ( basically resume compile flag )"
    message " --pkgrel-bump            : This is useful when youre clean recompiling pkg"
    echo " "
    echo " "
    message "###"
    message "# Docker options"
    message "###"
    message " -d or --docker           : This will make pkg builder use docker environment"
    message " -dr or --docker-reset    : This reset's docker container ( if it breaks for some reson )"
    message " --kde                    : Will use created container that has qt5 and qt6 preinstalled ( Add BEFORE -d option only )"
    message "     |- EXAMPLE: ./envsetup --kde -d -b plasma-workspace"
    message " --docker-shell           : This will only work with/without --kde option and wont take any other arg's"
    echo " "
    echo " "
    message "###"
    message "# ISO Creator options"
    message "###"
    message " --mkiso                  : This will prompt you do the iso creator menu ( makes LiveOS Installer CLI )"
    message " --mkiso-clean-cli        : Will skip mkiso menu and make clean base ISO"
    message " --mkiso-plasma-clean-cli : Will skip mkiso and make clean plasma-desktop ISO"
    message " --mkiso-xfce-clean-cli : Will skip mkiso and make clean xfce-desktop ISO"

    clean_tmp # Also clean tmp files before exit
    exit 1
}
