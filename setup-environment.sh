#!/bin/bash
# -*- mode: shell-script; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
#
# Copyright (C) 2012, 2013 O.S. Systems Software LTDA.
# Authored-by:  Otavio Salvador <otavio@ossystems.com.br>
#
# Copyright (C) 2014 aosp-hybris project
# Copyright (C) 2015 - 2019 coldnew's personal project
# Authored-by:  Yen-Chin, Lee <coldnew.tw@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Add options for the script
# Copyright (C) 2013 Freescale Semiconductor, Inc.

NCPU=`grep -c processor /proc/cpuinfo`
CWD=`pwd`
SRCDIR=$CWD/sources
PROGNAME="setup-environment"

TEMPLATES=$CWD/conf

# Always force overwrite config
FORCE_OVERWRITE_CONFIG=1

clean_up()
{
    unset EULA LIST_MACHINES VALID_MACHINE
    unset NCPU CWD TEMPLATES SHORTOPTS LONGOPTS ARGS PROGNAME
    unset generated_config updated
    unset MACHINE SDKMACHINE DISTRO OEROOT
    unset CURRENT_GIT_ID MASTER_GIT_ID SRCDIR
    unset TEMPLATES TEMPLATES_MACHINE
}

############################################################
# Local Helper Functions

error() {
    : << FUNCDOC
This function is used to simple show error message without exit.

parameter 1: error message

FUNCDOC

    echo -e "\n\033[31m\033[1mERROR: $1\033[0m\n"
}

select_config() {
    : << FUNCDOC
List supported machines in source/coldnew-layer/conf

FUNCDOC

    options=($(find ${TEMPLATES}/  -type d | awk -F/ '{print $NF}' | awk 'NF > 0'))
    select opt in "${options[@]}"
    do
        case "${options[@]}" in
            "q" | "quit" )
                break
                ;;
            *$opt*)
                echo "you chose $opt"
                MACHINE=$opt
                break
                ;;
            *) echo invalid option;;
        esac
    done
}

show_welcome() {
    : <<FUNCDOC
Show welcome message
FUNCDOC

    if [ -e $TEMPLATES_MACHINE/info.txt ]; then
        cat $TEMPLATES_MACHINE/info.txt
    elif [ -e $TEMPLATES/info.txt ]; then
        cat $TEMPLATES/info.txt
    else
        cat <<EOF

Welcome to Yocto BSP

The Yocto Project has extensive documentation about OE including a
reference manual which can be found at:
    http://yoctoproject.org/documentation

For more information about OpenEmbedded see their website:
    http://www.openembedded.org/

You can now run 'bitbake <target>'

Common targets are:
	core-image-minimal

EOF
    fi
}


############################################################
#### main

# check if already fetch source
if [ ! -e $CWD/sources ]; then
    error "please execute ./fetch-source.sh first!!"
    return
fi

# Disable root user
if [ "$(whoami)" = "root" ]; then
    error "ERROR: do not use the BSP as root. Exiting..."
    return
fi

# Make sure we get argument
if [ -z "$1" ]; then
    cat <<EOF
    USAGE: source setup-environment.sh <build dir>
EOF
    return
fi

# If dirname "$1" is the same as machine name, setup MACHINE variable
MACHINES=$(cd $TEMPLATES && find . -type d)
for i in ${MACHINES}; do
    if [[ "${1/\//}" == "${i/.\//}" ]]; then
        MACHINE="${i/.\//}"
        echo "Use match machine name: ${MACHINE}"
    fi
done

# Make user select MACHINE type
if [ -z "$MACHINE" ]; then

    echo 'Please selct machine: (q to exit)'
    select_config

    if [ -z "$MACHINE" ]; then
        error "ERROR: no MACHINE select, exit."
        return
    fi

    if [ ! -e $TEMPLATES/$MACHINE/local.conf ]; then
        error "ERROR: machine $MACHINE does not exist. exit"
        return
    fi
fi

# Setup openembedded root
OEROOT=$SRCDIR/poky
#if [[ "$MACHINE" == *"riscv"* ]]; then
#    echo "RISC-V architecture, use risc-poky instead."
#    OEROOT=$SRCDIR/riscv-poky
#fi

if [[ -e $SRCDIR/oe-core ]]; then
    OEROOT=$SRCDIR/oe-core
fi

cd $OEROOT

# Use user defines dir
. ./oe-init-build-env $CWD/$1 > /dev/null

# Clean up PATH, because if it includes tokens to current directories somehow,
# wrong binaries can be used instead of the expected ones during task execution
export PATH="`echo $PATH | sed 's/\(:.\|:\)*:/:/g;s/^.\?://;s/:.\?$//'`"

generated_config=
if [[ $FORCE_OVERWRITE_CONFIG -eq 1 ]]; then
    mv conf/local.conf conf/local.conf.bk

    # Generate the local.conf based on the private defaults
    TEMPLATES_MACHINE=$TEMPLATES/$MACHINE
    grep -v '^#\|^$' $TEMPLATES/local.conf > conf/local.conf
    grep -v '^#\|^$' $TEMPLATES_MACHINE/local.conf >> conf/local.conf

    # Copy layers config
    # If machine specific bblayers.conf exist, use it else use generic conf
    if [[ -e $TEMPLATES_MACHINE/bblayers.conf ]]; then
        cp $TEMPLATES_MACHINE/bblayers.conf conf/
    else
        cp $TEMPLATES/bblayers.conf conf/
    fi

    # Appedn user defined local.conf if exist
    if [[ -e $TEMPLATES/local.conf ]]; then
        grep -v '^#\|^$' $TEMPLATES/local.conf >> conf/local.conf
    fi

    if [[ -e $TEMPLATES/$MACHINE.conf ]]; then
        grep -v '^#\|^$' $TEMPLATES/$MACHINE.conf >> conf/local.conf
    fi

    # Append user defined bblayers if exist
    if [[ -e $TEMPLATES/$MACHINE.bblayers.conf ]]; then
        cat $TEMPLATES/$MACHINE.bblayers.conf >> conf/bblayers.conf
    fi

    for s in $HOME/.oe $HOME/.yocto; do
        if [[ -e $s/site.conf ]]; then
            echo "Linking $s/site.conf to conf/site.conf"
            ln -s $s/site.conf conf
        fi
    done

    generated_config=1
fi

# show welcome message
show_welcome

# Unset All tmp variables
clean_up
