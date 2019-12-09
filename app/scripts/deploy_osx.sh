#!/bin/bash

# TODO: check "appdata" file and detect location of $ROOT_DIR if it is there

ROOT_DIR="$HOME/.bitdust"
SOURCE_DIR="${ROOT_DIR}/src"
SOURCE_UI_DIR="${ROOT_DIR}/ui"
VENV_DIR="${ROOT_DIR}/venv"
PYTHON_BIN="${ROOT_DIR}/venv/bin/python"
PIP_BIN="${ROOT_DIR}/venv/bin/pip"
BITDUST_PY="${SOURCE_DIR}/bitdust.py"
BITDUST_COMMAND_FILE="${ROOT_DIR}/bitdust"
GLOBAL_COMMAND_FILE="/usr/local/bin/bitdust"


if [[ "$1" == "stop" ]]; then
    echo ''
    echo '##### Stopping BitDust'
    $PYTHON_BIN $BITDUST_PY stop
    echo ''
    echo 'DONE'
    exit 0;
fi


if [[ "$1" == "restart" ]]; then
    echo ''
    echo '##### Restarting BitDust'
    $PYTHON_BIN $BITDUST_PY restart
    echo ''
    echo 'DONE'
    exit 0;
fi


if [[ ! -e $ROOT_DIR ]]; then
    echo ''
    echo "##### Prepare BitDust Home folder"
    mkdir -p $ROOT_DIR
else
    echo ''
    echo "##### BitDust Home folder found"
fi


cd "$ROOT_DIR"


gitok=`which git`

if [[ ! $gitok ]]; then
    GIT_BIN="${ROOT_DIR}/git/bin/git"
    echo ''
    echo "##### Prepare Git binariy files"
    mkdir -p "${ROOT_DIR}/git/bin/"
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    cp "${CURRENT_DIR}/../../build_resources/macos/git" "$ROOT_DIR/git/bin/"
else
    GIT_BIN=`which git`
    echo ''
    echo "##### Git binariy files already installed globally"
fi


pipok=`which pip`
pipuserok=`PATH="$HOME/Library/Python/2.7/bin:$PATH" which pip`
venvok=`which virtualenv`
venvuserok=`PATH="$HOME/Library/Python/2.7/bin:$PATH" which virtualenv`


if [[ ! $pipok ]]; then
    if [[ ! $pipuserok ]]; then
        echo ''
        echo '##### Installing PIP installer for current user'
        python -m ensurepip -U -v --user
    else
        echo ''
        echo '##### PIP installer already configured for current user'
    fi
else
    echo ''
    echo '##### PIP installer already configured globally'
fi


if [[ ! $venvok ]]; then
    if [[ ! $venvuserok ]]; then
        echo ''
        echo '##### Preparing Virtualenv script for current user'
        python -m pip install --upgrade virtualenv --user
    else
        echo ''
        echo '##### Virtualenv script already installed for current user'
    fi
else
    echo ''
    echo '##### Virtualenv script already installed globally'
fi


if [[ ! -e $SOURCE_DIR ]]; then
    echo ''
    echo "##### Downloading BitDust source files from Git repository"
    mkdir -p "$SOURCE_DIR"
    $GIT_BIN clone --depth=1 "https://github.com/bitdust-io/public.git" "$SOURCE_DIR"
else
    echo ''
    echo "##### BitDust source files already cloned locally"
    cd "$SOURCE_DIR"
    echo ''
    echo "##### Updating BitDust source files from Git repository"
    $GIT_BIN fetch
    echo ''
    echo "##### Refreshing BitDust source files"
    $GIT_BIN reset --hard origin/master
    cd ..
fi


if [[ ! -e $SOURCE_UI_DIR ]]; then
    echo ''
    echo "##### Downloading BitDust UI source files from Git repository"
    mkdir -p $SOURCE_UI_DIR
    $GIT_BIN clone --single-branch --branch gh-pages --depth=1 "https://github.com/bitdust-io/ui.git" "$SOURCE_UI_DIR"
else
    echo ''
    echo "##### BitDust UI source files already cloned locally"
    cd $SOURCE_UI_DIR
    echo ''
    echo "##### Updating BitDust UI source files from Git repository"
    $GIT_BIN fetch
    echo ''
    echo "##### Refreshing BitDust UI source files"
    $GIT_BIN reset --hard origin/gh-pages
    cd ..
fi


if [[ ! -e $PIP_BIN ]]; then
    echo ''
    echo "##### Preparing Python virtual environment"
    PATH="$HOME/Library/Python/2.7/bin:$PATH" python $BITDUST_PY install
else
    # TODO: this is slow and can fail if user is offline...
    # this actually must be only executed when requirements.txt was changed
    echo ''
    echo "##### Updating Python virtual environment"
    $PIP_BIN install -U -r $SOURCE_DIR/requirements.txt
fi


if [[ ! $GLOBAL_COMMAND_FILE ]]; then
    echo ''
    echo "##### Create system-wide shell command"
    ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
fi


echo ''
echo "##### Starting BitDust as a daemon process"
$GLOBAL_COMMAND_FILE daemon


echo ''
echo 'DONE'

exit 0
