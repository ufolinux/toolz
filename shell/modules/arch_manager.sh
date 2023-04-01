get_arch() {
	ARCH=$(uname -m)
	msg_debug "[ System arch is ]: ${ARCH}"
}

arch_check_and_warn() {
	# Func name says it
	wants=$1
	has=$(uname -m)

	if [ "$wants" = "$has" ]; then
		true
	else
		msg_warning "Youre machine isn't based on target arch, make sure to use qemu and targeted rootfs for builds!!!"
	fi
}

set_aarch64() {
	# Make sure to failsafe check and warn dev if host if different arch system
	arch_check_and_warn aarch64

	# Now do the trick
	if [ -f "$TOOL_TEMP/is_arch" ]; then
		msg_debug "Already set to AArch64"
	else
		msg_debug "Arch set to AArch64"
		echo 'aarch64' > $TOOL_TEMP/is_arch
	fi
}

set_x86_64() {
	# Now do the trick
	if [ -f "$TOOL_TEMP/is_arch" ]; then
		msg_debug "Already set to X86_64"
	else
		msg_debug "Arch set to X86_64"
		echo 'x86_64' > $TOOL_TEMP/is_arch
	fi
}

set_arch() {
	# name says it again

	has=$(uname -m)
	if [ "x86_64" = $has ]; then
		set_x86_64
	elif [ "aarch64" = $has ]; then
		set_aarch64
	else
		msg_error "You're arch is unsupported - ${has}"
	fi
}

get_target_arch() {
	cat "$TOOL_TEMP/is_arch"
}

# TODO: Finish this here ( Currently using pkg_location hax )
set_arch_dir() {
	# Here we will set a pkgbuild dir for setup if user has predefined
	# its location by giving a new build script argument

	export ARCH=$(cat $TOOL_TEMP/is_arch)

	if [ $ARCH == x86_64 ]; then
		message "Using X86_64 PKGBUILD files"
	elif [ $ARCH == aarch64 ]; then
		message "Using AArch64 PKGBUILD files"
	else
		msg_error "Didnt find any supported arch"
	fi
}
