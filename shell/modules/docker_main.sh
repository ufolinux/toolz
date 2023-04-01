##
# Here are functions related for docker functions
##

docker_initial_setup() {
    # Start dockerd from systemctl
    sudo systemctl restart docker

    if [ -f $TOOL_CHECKS/docker_ready ]; then
        msg_debug "Docker image is already downloaded, starting the container now"
        message "Starting docker container ( sudo may be needed )"
        docker_container_start

        sleep 2

    else
        message "Docker initial setup will ask for passwd"
        sudo docker pull ${DOCKER_IMAGE_NAME}:latest

        sleep 1

        # Setup base docker container
        docker_setup_container

        # Start our new container
        docker_container_start

        sleep 1

        docker_initial_sysedit

        # Tell the script that docker image is pulled
        touch $TOOL_CHECKS/docker_ready

        docker_check_kde_health
    fi
}

docker_check_kde_health() {
    # Lets make a image from custom container
    if [ ! -f $TOOL_CHECKS/docker_kde_ready ]; then
        docker_run_cmd rm -rf /var/lib/kepler/sync/*
        docker_run_cmd kepler -Syu --needed --noconfirm --disable-download-timeout qt5 qt6

        message "Creating new image for kde build env called ( ${DOCKER_CONTAINER_KDE_NAME} )"
        sudo docker commit $DOCKER_CONTAINER_NAME $DOCKER_CONTAINER_KDE_NAME

        docker_reset
    fi
}

# Here are needed changes for our development area/env that arent made by default image builder
docker_initial_sysedit() {
    # Reset kepler sync folder
    docker_run_cmd rm -rf /var/lib/kepler/sync/*

    set +e

    # Add developer user ( used to build pkg's without root
    docker_run_cmd useradd developer -m -g wheel

    # Copy over local kepler.conf
    docker_run_cmd cp -f /home/developer/$TOOL_MAIN_NAME/tools/docker/kepler.conf /etc/kepler.conf

    # Perms fixes + kepler changes
    docker_run_cmd bash -c /home/developer/$TOOL_MAIN_NAME/tools/docker/developer.sh

    set -e

    # Also upgrade base system before installing new stuff
    docker_run_cmd kepler -Syu --needed --noconfirm --disable-download-timeout

    # Make sure that container has sudo installed with
    docker_run_cmd kepler --needed --noconfirm --disable-download-timeout -Sy sudo nano mpfr mpc base-devel m4 git grep gawk file

    docker_run_cmd bash -c /home/developer/$TOOL_MAIN_NAME/tools/docker/fix_sudo.sh

    # Apply git global changes ( just in case repo tool is used somewhere )
    docker_run_cmd git config --global user.email "cybersecbyte@gmail.com"
    docker_run_cmd git config --global user.name "Cybersecbyte"
    docker_run_cmd git config --global color.ui false
}

docker_setup_container() {
    sudo docker container create \
    --name $DOCKER_CONTAINER_NAME \
    --volume $P_ROOT:$DOCKER_USER_FOLDER/$TOOL_MAIN_NAME \
    --tty \
    ${DOCKER_IMAGE_NAME} /bin/bash
}

docker_setup_container_kde() {
    sudo docker container create \
    --name $DOCKER_CONTAINER_KDE_NAME \
    --volume $P_ROOT:$DOCKER_USER_FOLDER/$TOOL_MAIN_NAME \
    --tty \
    $DOCKER_CONTAINER_KDE_NAME /bin/bash
}

docker_container_start() {
    if [ "${DOCKER_CONTAINER_KDE}" = true ]; then
        docker_container_start_kde
    else
        docker_container_start_normal
    fi
}

docker_container_start_normal() {
    sudo docker start $DOCKER_CONTAINER_NAME >/dev/null
}

docker_container_start_kde() {
    sudo docker start $DOCKER_CONTAINER_KDE_NAME >/dev/null
}

docker_reset() {
    docker_set_kde_status

    if [ "${DOCKER_CONTAINER_KDE}" = true ]; then
        docker_reset_kde
        message "Docker reset is done for: ${DOCKER_CONTAINER_KDE_NAME}"
    else
        docker_reset_dev
        message "Docker reset is done for: ${DOCKER_CONTAINER_NAME}"
    fi
}

docker_reset_dev() {
    message "Stopping old container ( $DOCKER_CONTAINER_NAME )"

    sudo docker container stop $DOCKER_CONTAINER_NAME
    sleep 1

    sudo docker container rm $DOCKER_CONTAINER_NAME
    sleep 2

    docker_setup_container
    sleep 1

    sudo docker start $DOCKER_CONTAINER_NAME >/dev/null
    sleep 3

    docker_initial_sysedit

    # Now clean tmp
    clean_tmp
}

# Only applies for drunk_kde
docker_reset_kde() {
    message "Stopping old container ( $DOCKER_CONTAINER_KDE_NAME )"

    sudo docker container stop $DOCKER_CONTAINER_KDE_NAME
    sleep 1

    sudo docker container rm $DOCKER_CONTAINER_KDE_NAME
    sleep 2

    docker_setup_container_kde
    sleep 1

    docker_container_start_kde
    sleep 3

    docker_initial_sysedit

    # Update / Upgrade qt*
    docker_run_cmd kepler --needed --noconfirm --disable-download-timeout -Su qt5 qt6

    # Now clean tmp
    clean_tmp
}

docker_set_kde_status() {
    msg_debug "Getting proper container name for our usage"

    if [ ! -f $TOOL_TEMP/docker001 ]; then
        touch $TOOL_TEMP/docker001
    fi

    if [ "$(cat $TOOL_TEMP/docker001)" == "$DOCKER_CONTAINER_KDE_NAME" ]; then
        echo 'true' > $TOOL_CHECKS/docker_kde
        export DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_KDE_NAME}
    else
        echo 'false' > $TOOL_CHECKS/docker_kde
    fi

    # Re-export the default container name ( basically overwrite default one to kde's )
    export DOCKER_CONTAINER_KDE=$(cat $TOOL_CHECKS/docker_kde)

    msg_debug "KDE Switch is now: ${DOCKER_CONTAINER_KDE} + ${DOCKER_CONTAINER_NAME}"
}

# Start the container
docker_start() {
    msg_debug "DOCKER: Executed bash shell"
    sudo docker exec --interactive --tty $DOCKER_CONTAINER_NAME bash
}

# ROOT run cmd
docker_run_cmd() {
    msg_debug "DOCKER: $@"
    sudo docker exec --tty $DOCKER_CONTAINER_NAME $@
}

# developer user bash shell
docker_user_start() {
    msg_debug "DOCKER: Executed bash shell"
    sudo docker exec --interactive --tty $DOCKER_CONTAINER_NAME su developer -c bash
}

# developer run cmd
docker_user_run_cmd() {
    msg_debug "DOCKER: $@"
    sudo docker exec --tty $DOCKER_CONTAINER_NAME su developer -c "$@"
}

