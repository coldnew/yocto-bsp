#!/bin/bash
# -*- mode: shell-script; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
#
# Copyright (C) 2012, 2013 O.S. Systems Software LTDA.
# Authored-by:  Otavio Salvador <otavio@ossystems.com.br>
#
# Copyright (C) 2014 aosp-hybris project
# Copyright (C) 2015-2020 coldnew's personal project
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

############################################################
# Variables

# SDIR store this script path
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CWD=`pwd`
SRCDIR=${SDIR}/../../sources

############################################################
# Local Helper Functions

error() {
    : << FUNCDOC
This function is used to simple show error message without exit.

parameter 1: error message

FUNCDOC

    echo -e "\n\033[31m\033[1mERROR: $1\033[0m\n"
}

############################################################
#### main

# check if sources directory exist
if [ ! -e ${SRCDIR} ]; then
    error "Can not find directory: ${SRCDIR}"
    return
fi

# Disable root user
if [ "$(whoami)" = "root" ]; then
    error "ERROR: do not use the BSP as root. Exiting..."
    return
fi

# setup OEROOT
OEROOT=$SRCDIR/poky
if [[ -e $SRCDIR/oe-core ]]; then
    OEROOT=$SRCDIR/oe-core
fi

cd $OEROOT

# Use user defines dir
. ./oe-init-build-env $CWD > /dev/null

# show welcome message
if [ -e $CWD/info.txt ]; then
    cat $CWD/info.txt
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
