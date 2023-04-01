#!/bin/bash

set -e -o pipefail -u

##
#   Export some needed things for head script to work with
##

# Dont allow to run this script in other places than specified symlink dir ( So no unknown issues occure )
if [ -f build/toolset/envsetup.sh ];then
    cd "$(dirname "$0")"
else
    echo "Dont run this in other places than its symlink root dir ( Only in a project root dir that has folder called setup )!!!"
    exit 1
fi

export P_ROOT=$(pwd)

# Load all modules with load_module script
source $P_ROOT/build/toolset/load_modules.sh

dialog_main
