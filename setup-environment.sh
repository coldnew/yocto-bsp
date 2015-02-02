#!/bin/sh
# -*- mode: shell-script; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
#
# Copyright (C) 2012, 2013 O.S. Systems Software LTDA.
# Authored-by:  Otavio Salvador <otavio@ossystems.com.br>
#
# Copyright (C) 2014 aosp-hybris project
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
PROGNAME="setup-environment"

# Always force overwrite config
FORCE_OVERWRITE_CONFIG=1

usage()
{
    echo -e "\nUsage: source $PROGNAME <build-dir>
    <build-dir>: specifies the build directory location (required)

If undefined, this script will set \$MACHINE to 'goldfisharmv7 (armv7ahf)'.
"

    ls sources/*/conf/machine/*.conf > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "
Supported machines: `echo; ls sources/*/conf/machine/*.conf \
| sed s/\.conf//g | sed -r 's/^.+\///' | xargs -I% echo -e "\t%"`

To build for a machine listed above, run this script as:
MACHINE=<machine> source $PROGNAME <build-dir>
"
    fi
}

clean_up()
{
   unset EULA LIST_MACHINES VALID_MACHINE
   unset NCPU CWD TEMPLATES SHORTOPTS LONGOPTS ARGS PROGNAME
   unset generated_config updated
   unset MACHINE SDKMACHINE DISTRO OEROOT
}

# get command line options
SHORTOPTS="h"
LONGOPTS="help"

ARGS=$(getopt --options $SHORTOPTS  \
  --longoptions $LONGOPTS --name $PROGNAME -- "$@" )
# Print the usage menu if invalid options are specified
if [ $? != 0 -o $# -lt 1 ]; then
   usage && clean_up
   return 1
fi

eval set -- "$ARGS"
while true;
do
    case $1 in
        -h|--help)
           usage
           clean_up
           return 0
           ;;
        --)
           shift
           break
           ;;
    esac
done

if [ "$(whoami)" = "root" ]; then
    echo "ERROR: do not use the BSP as root. Exiting..."
fi

if [ -z "$MACHINE" ]; then
    MACHINE='raspberrypi'
fi

# Check the machine type specified
LIST_MACHINES=`ls -1 $CWD/sources/*/conf/machine`
VALID_MACHINE=`echo -e "$LIST_MACHINES" | grep ${MACHINE}.conf$ | wc -l`
if [ "x$MACHINE" = "x" ] || [ "$VALID_MACHINE" = "0" ]; then
    echo -e "\nThe \$MACHINE you have specified ($MACHINE) is not supported by this build setup"
    usage && clean_up
    return 1
else
    if [ ! -e $1/conf/local.conf.sample ]; then
        echo "Configuring for ${MACHINE}"
    fi
fi

# If user's local.conf not exist, generate it
if [ ! -e $CWD/conf/local.conf ]; then

        cat >> $CWD/conf/local.conf << EOF
## User's local conf
#
# This file will not be track by git

BB_NUMBER_THREADS = '$NCPU'
PARALLEL_MAKE = '-j $NCPU'

# CONF_VERSION is increased each time build/conf/ changes incompatibly and is used to
# track the version of this file when it was generated. This can safely be ignored if
# this doesn't mean anything to you.
CONF_VERSION = "1"

#MACHINE = "qemuarm"
#SDKMACHINE = "i686"

# Enable build history to see details of image
#INHERIT += "buildhistory"
#BUILDHISTORY_COMMIT = "1"

# Enable prservice to auto incremental PR value
# see: https://wiki.yoctoproject.org/wiki/PR_Service
#PRSERV_HOST = "localhost:0"

# Uncomment this to delete work files as the build progresses rather than
# keeping them around, which saves a lot of disk space. However, if any
# problems arise it can be useful to have the work files to examine, which
# is why it is off by default.
#INHERIT += "rm_work"

EOF
fi

OEROOT=sources/poky
if [ -e sources/oe-core ]; then
    OEROOT=sources/oe-core
fi

cd $OEROOT

. ./oe-init-build-env $CWD/$1 > /dev/null

# if conf/local.conf not generated, no need to go further
if [ ! -e conf/local.conf ]; then
    clean_up && return 1
fi

# Clean up PATH, because if it includes tokens to current directories somehow,
# wrong binaries can be used instead of the expected ones during task execution
export PATH="`echo $PATH | sed 's/\(:.\|:\)*:/:/g;s/^.\?://;s/:.\?$//'`"

generated_config=
if [ $FORCE_OVERWRITE_CONFIG -eq 1 ]; then
    mv conf/local.conf conf/local.conf.bk

    # Generate the local.conf based on the Yocto defaults
    TEMPLATES=$CWD/conf
    grep -v '^#\|^$' $TEMPLATES/local.conf.sample > conf/local.conf

    # Append user's local.conf
    grep -v '^#\|^$' $TEMPLATES/local.conf >> conf/local.conf

    # Copy layers config
    cp $TEMPLATES/bblayers.conf conf/

    for s in $HOME/.oe $HOME/.yocto; do
        if [ -e $s/site.conf ]; then
            echo "Linking $s/site.conf to conf/site.conf"
            ln -s $s/site.conf conf
        fi
    done

    generated_config=1
fi

cat <<EOF

Welcome to aosp-hybris BSP

The Yocto Project has extensive documentation about OE including a
reference manual which can be found at:
    http://yoctoproject.org/documentation

For more information about OpenEmbedded see their website:
    http://www.openembedded.org/

You can now run 'bitbake <target>'

Common targets are:
    aosp-hybris-minimal

EOF

clean_up
