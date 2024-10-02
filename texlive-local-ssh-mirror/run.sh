#!/usr/bin/env bash

# exit immediately on failure (even when piping), treat unset variables and
# parameters as an error, and disable filename expansion (globbing)
set -eufo pipefail

revs=(  59745  66594  70951  74725)
tags=( 2021.3 2023.0 2024.2 2025.2)

# direct subversion requests to localhost server
# $ sudo sh -c 'echo "127.0.0.1   www.tug.org" >> /etc/hosts'

SERVER_DIR=svn
SVN_DIR=texlive.svn
GIT_DIR=texlive.git

# checkout the git repository
if [ ! -d $GIT_DIR ]; then
    git clone https://git.texlive.info/texlive ${GIT_DIR}
fi

# create the subversion repository and start the server
mkdir svn
svnadmin create ${SERVER_DIR}/texlive
sed --in-place --expression='s/# anon-access = read/anon-access = write/' ${SERVER_DIR}/texlive/conf/svnserve.conf
svnserve --daemon --listen-host=0.0.0.0 --root=${SERVER_DIR}

# checkout the empty repository
svn co svn://www.tug.org/texlive ${SVN_DIR}

# copy commits based on revs and tags
next_rev=0
for (( i=0; i<${#revs[@]}; i++ ))
do
    rev=${revs[i]}
    tag=texlive-${tags[i]}

    echo "rev=${rev} tag=${tag}"

    # create 'fake' empty Subversion commits up to the desired revision number
    (echo -e 'SVN-fs-dump-format-version: 2\n\n' ; for (( j=${next_rev}; j<${rev}; j++ )); do echo -e "Revision-number: ${j}\nProp-content-length: 56\nContent-length: 56\n\nK 8\nsvn:date\nV 27\n1970-01-01T00:00:00.000000Z\nPROPS-END\n"; done) | svnadmin load --quiet ${SERVER_DIR}/texlive/
    #(echo -e 'SVN-fs-dump-format-version: 2\n\n' ; for j in `seq ${prev_rev} $((${rev} - 1))`; do echo -e "Revision-number: ${j}\nProp-content-length: 56\nContent-length: 56\n\nK 8\nsvn:date\nV 27\n1970-01-01T00:00:00.000000Z\nPROPS-END\n"; done) | svnadmin load ${SERVER_DIR}/texlive/
    next_rev=$((${rev} + 1))

    # copy the files from the Git repository
    pushd ${GIT_DIR}
    echo "hard reset"
    git reset --hard
    git clean -fdx --quiet
    echo "checking out ${tag}"
    git checkout origin/tags/${tag}
    popd

    # move files from git checkout to svn checkout
    #rm -rf ${SVN_DIR}/tags
    mkdir -p ${SVN_DIR}/tags/${tag}
    mv ${GIT_DIR}/* ${SVN_DIR}/tags/${tag}

    # add/commit to the Subversion repository
    pushd ${SVN_DIR}
    svn add --quiet --force *
    svn commit --quiet --message "rev=${rev} tag=${tag}"
    popd

    # move files from svn checkout back to git checkout
    mv ${SVN_DIR}/tags/${tag}/* ${GIT_DIR}
    rmdir ${SVN_DIR}/tags/${tag}
done
