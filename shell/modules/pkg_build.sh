##
# Here we will declare function how and where to work with pkg's
##

build_pkg() {
    msg_debug "EXECUTED - Build pkg"

    # Source some env build flags
    if [[ -f $TOOL_TEMP/envvar00* ]]; then
        source $TOOL_TEMP/envvar001 # Specifies if pkgrel bumping is needed ( if not then true for skip )
    fi

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
        PKG_NAME=$(basename "${PKG_LIST[p]}")

        # Update ic_compiling ( used for lock function to notify user what is WIP currently )
        rm -f $TOOL_TEMP/builds # remove it even if it dosent exist
        echo "IS_COMPILING=${PKG_NAME}" > $TOOL_TEMP/builds

        # Just in case if no -f / --no-extract has been specified
        touch $TOOL_TEMP/tmpvar999
        MAKEPKG_EXTRA_ARG="$(cat $TOOL_TEMP/tmpvar* | tr -d '\n' )"

        echo " " # hacky Newline?
        msg_debug ---
        msg_debug // Specified makepkg "flag's"
        msg_debug $MAKEPKG_EXTRA_ARG
        msg_debug ---
        echo " " # hacky Newline?

        # Find its location
        find_pkg_location

        cd $PKG_PATH

        if [ -f PKGBUILD  ]; then
            msg_debug "Found correct directory with PKGBUILD"
        else
            msg_error "directory or PKGBUILD is missing for asked pkg"
        fi

        if [ "$TOOL_SKIPBUMP" = false ];then
            # Make a copy of PKGBUILD for release ver bumper
            cp PKGBUILD PKGBUILD_NEW
            bump_rel
        fi

        sleep 1
        # Resolve + install needed deps of this pkg
        resolve_dep
        install_dep

        msg_spacer

        msg_debug ---
        msg_debug // BASIC ORIG INFO
        msg_debug PKGNAME=$pkgname
        msg_debug PKGVER=$pkgver
        msg_debug PKGREL=$pkgrel
        msg_debug ---
        echo " " # hacky Newline?

        # Lets allow error's here ( we handle it by diff )
        set +e

        # Remove existing *pkg* file
        rm -f ${PKG_NAME}-*.pkg.tar.gz

        # Start the compiler for pkg
        # ( LC_CTYPE export is needed for bsdtar, without it we get error's about it for some tarballs )
        if [ "$TOOL_SKIPBUMP" = false ];then
            LC_CTYPE=en_US.UTF-8 makepkg -p PKGBUILD_NEW $MAKEPKG_EXTRA_ARG

            #Now as the build finished we move our new PKGBUILD here
            cp -f PKGBUILD_NEW PKGBUILD
            rm -f PKGBUILD_NEW
        else
            LC_CTYPE=en_US.UTF-8 makepkg $MAKEPKG_EXTRA_ARG
        fi

        # Cleaning temp is needed, otherwise we have lock on and new compile of pkg cant be started ( basically clean on error here )
        echo $TOOL_SKIPBUMP
        if [ "$TOOL_SKIPBUMP" = false ];then
            if [ -f $PKG_NAME-$PKG_VERSION-$srel-$P_ARCH.pkg.tar.gz ]; then
                msg_debug pkg got compiled
            else
                clean_tmp
                msg_error pkg didnt compile, now error!
            fi
        else
            if [ -f $PKG_NAME-$PKG_VERSION-$pkgrel-$P_ARCH.pkg.tar.gz ]; then
                msg_debug pkg got compiled
            else
                clean_tmp
                msg_error pkg didnt compile, now error!
            fi
        fi

        set -e
        msg_spacer

        if [ "$TOOL_SKIPBUMP" = false ];then
            mkdir -p $TOOL_OUT/pkgs/$P_ARCH/$WHAT_AM_I/

            cp -f $PKG_NAME-$PKG_VERSION-$srel-$P_ARCH.pkg.tar.gz $TOOL_OUT/pkgs/$P_ARCH/$WHAT_AM_I/
            # Tell dev where the pkg is located
            message "Build successfully done, and pkg file is located at out/pkgs/$P_ARCH/$WHAT_AM_I/$PKG_NAME-$PKG_VERSION-$srel-$P_ARCH.pkg.tar.gz"
        else
            mkdir -p $TOOL_OUT/pkgs/$P_ARCH/$WHAT_AM_I/

            cp -f $PKG_NAME-$PKG_VERSION-$pkgrel-$P_ARCH.pkg.tar.gz $TOOL_OUT/pkgs/$P_ARCH/$WHAT_AM_I/
            # Tell dev where the pkg is located
            message "Build successfully done, and pkg file is located at out/pkgs/$P_ARCH/$WHAT_AM_I/$PKG_NAME-$PKG_VERSION-$pkgrel-$P_ARCH.pkg.tar.gz"
        fi
    done
}

bump_rel() {
    # This function is only used if TOOL_SKIPBUMP is true
    # Basically bumps pkgrel up by +1 for every pkg that it is used with, check --help for more info
    cd $PKG_PATH

    source PKGBUILD
    bump_rel=$((${pkgrel} + 1 ))
    export srel=$bump_rel
    # Now lets modify out PKGBUILD with new release string
    sed -i "s/pkgrel=${pkgrel}/pkgrel=${bump_rel}/g" PKGBUILD_NEW
}

build_pkg_docker() {
    docker_set_kde_status

    sleep 1

    docker_initial_setup

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
    rm -f $TOOL_TEMP/builds $TOOL_TEMP/.builder_locked

    PKG_NAME=$(basename "${PKG_LIST[p]}")
    msg_debug "List of packages to build: ${PKG_LIST}"

    # --leave-tmp is used here because the pkg's here are looped until every
    # single of them gets built, but as the script ends in docker then it tries to
    # clean the tmp that has our flags give by main script here

    message "DOCKER: Started compiling package $PKG_NAME"
    docker_user_run_cmd "cd ~/$TOOL_MAIN_NAME && ./UFO --leave-tmp -b ${PKG_NAME}"

    rm -f $TOOL_TEMP/builds $TOOL_TEMP/.builder_locked

    # Reset is needed for containers so they start to build new package without older pkg dependencies
    # Keeps hidden linked deps results lower
    docker_reset

    done

    rm -f $TOOL_TEMP/.keep_tmp
}
