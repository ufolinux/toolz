#!/bin/bash

# Symlink the main toolset runner to project root if not present
if [ ! -f envsetup ]; then

    if [ ! -f build/toolset/envsetup.sh ]; then
        echo "Cd to repo synced folder and run me again!!!"
    fi

    ln -sf build/toolset/envsetup.sh envsetup

    echo "Now repo is initially set-up and youre good to run envsetup --help"

    else
        echo "Project already is initially runned"
fi
