#!/bin/bash
#
# Copyright (C) 2015 Yen-Chine, Lee <coldnew.tw@gmail.com>
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

############################################################
#### Initial system information
############################################################
CWD=`pwd`

############################################################
#### Repo
############################################################

# repo tracking branch and source
GITREPO=${GITREPO:-"https://github.com/coldnew/yocto-bsp-manifest.git"}
BRANCH=${BRANCH:-master}

# where to find repo tools
REPO=${REPO:-./repo}

# user configs repo sync flags
REPO_SYNC_FLAGS="${REPO_SYNC_FLAGS:-}"

repo_sync () {
    rm -rf .repo/manifest* &&
    $REPO init -u $GITREPO -b $BRANCH -m $1.xml &&
    $REPO sync $REPO_SYNC_FLAGS
    ret=$?
    if [ "$GITREPO" = "$GIT_TEMP_REPO" ]; then
        rm -rf $GIT_TEMP_REPO
    fi
    if [ $ret -ne 0 ]; then
        echo "Repo sync failed, use default manifest"
        repo_sync "default"
        (exit -1)
    fi
}

# get the newliest repo command if it does not exist
if [ ! -f repo ]; then
    echo "repo command not fount, download it"
    curl https://storage.googleapis.com/git-repo-downloads/repo  > repo
    chmod +x repo
fi

############################################################
#### Local config
############################################################

if [ ! -f .local_config ]; then
        cat >> .local_config << EOF
#!/bin/sh

# manifest source
GITREPO=${GITREPO}

# manifest branch
BRANCH="${BRANCH}"

# where to find repo tool
REPO="${REPO}"

# repo sync flags
#
#  -f, --force-broken    continue sync even if a project fails to sync
#  -l, --local-only      only update working tree, don't fetch
#  -n, --network-only    fetch only, don't update working tree
#  -d, --detach          detach projects back to manifest revision
#  -q, --quiet           be more quiet
#  -j JOBS, --jobs=JOBS  number of projects to fetch simultaneously
#  -s, --smart-sync      smart sync using manifest from a known good build
REPO_SYNC_FLAGS=""

EOF
fi

# load local-config if exist
[[ -e .local_config ]] && source .local_config

############################################################
#### show usage
############################################################

show_usage () {
    cat <<- EOF

Usage: ./fetch-source.sh

EOF

}

############################################################
#### main
############################################################

repo_sync "default"
