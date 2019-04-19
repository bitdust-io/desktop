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
    echo '##### Stopping BitDust...'
    $PYTHON_BIN $BITDUST_PY stop
    exit 0;
fi


if [[ "$1" == "restart" ]]; then
    echo ''
    echo '##### Restarting BitDust...'
    $PYTHON_BIN $BITDUST_PY restart
    exit 0;
fi


if [[ ! -e $ROOT_DIR ]]; then
    echo ''
    echo "##### Create BitDust Home folder at $ROOT_DIR"
    mkdir -p $ROOT_DIR
else
    echo ''
    echo "##### BitDust Home folder found at $ROOT_DIR"
fi


cd "$ROOT_DIR"


gitok=`which git`

if [[ ! $gitok ]]; then
    GIT_BIN="${ROOT_DIR}/git/bin/git"
    echo ''
    echo "##### Copy GIT binariy from distribution to $GIT_BIN"
    mkdir -p "${ROOT_DIR}/git/bin/"
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    cp "${CURRENT_DIR}/../../build_resources/macos/git" "$ROOT_DIR/git/bin/"
else
    GIT_BIN=`which git`
    echo ''
    echo "##### GIT already installed globally at $GIT_BIN"
fi


pipok=`which pip`
pipuserok=`PATH="$HOME/Library/Python/2.7/bin:$PATH" which pip`
venvok=`which virtualenv`
venvuserok=`PATH="$HOME/Library/Python/2.7/bin:$PATH" which virtualenv`


if [[ ! $pipok ]]; then
    if [[ ! $pipuserok ]]; then
        echo ''
        echo '##### Installing PIP for current user'
        python -m ensurepip -U -v --user
    else
        echo ''
        echo '##### PIP already installed for current user'
    fi
else
    echo ''
    echo '##### PIP already installed globally'
fi


if [[ ! $venvok ]]; then
    if [[ ! $venvuserok ]]; then
        echo ''
        echo '##### Installing Virtualenv for current user'
        python -m pip install --upgrade virtualenv --user
    else
        echo ''
        echo '##### Virtualenv already installed for current user'
    fi
else
    echo ''
    echo '##### Virtualenv already installed globally'
fi


if [[ ! -e $SOURCE_DIR ]]; then
    echo ''
    echo "##### Сloning source code of BitDust project to $SOURCE_DIR"
    mkdir -p "$SOURCE_DIR"
    $GIT_BIN clone --depth=1 "git://github.com/bitdust-io/public.git" "$SOURCE_DIR"
else
    echo ''
    echo "##### BitDust source code already cloned locally in $SOURCE_DIR"
    cd "$SOURCE_DIR"
    echo ''
    echo "##### Running 'git fetch' in $SOURCE_DIR"
    $GIT_BIN fetch
    echo ''
    echo "##### Running 'git reset --hard origin/master' in $SOURCE_DIR"
    $GIT_BIN reset --hard origin/master
    cd ..
fi


if [[ ! -e $SOURCE_UI_DIR ]]; then
    echo ''
    echo "##### Сloning source code of BitDust UI in $SOURCE_UI_DIR"
    mkdir -p $SOURCE_UI_DIR
    $GIT_BIN clone --depth=1 "git://github.com/bitdust-io/web.git" "$SOURCE_UI_DIR"
else
    echo ''
    echo "##### BitDust UI source code already cloned locally in $SOURCE_UI_DIR"
    cd $SOURCE_UI_DIR
    echo ''
    echo "##### Running 'git fetch' in $SOURCE_UI_DIR"
    $GIT_BIN fetch
    echo ''
    echo "##### Running 'git reset --hard origin/master' in $SOURCE_UI_DIR"
    $GIT_BIN reset --hard origin/master
    cd ..
fi


if [[ ! -e $VENV_DIR ]]; then
    echo ''
    echo "##### Installing BitDust, virtual environment location is $VENV_DIR"
    PATH="$HOME/Library/Python/2.7/bin:$PATH" python $BITDUST_PY install
else
    # TODO: this is slow and can fail if user is offline...
    # this actually must be only executed when requirements.txt was changed
    echo ''
    echo '##### Updating BitDust virtual environment in $VENV_DIR'
    $PIP_BIN install -U -r $SOURCE_DIR/requirements.txt
fi


if [[ ! $GLOBAL_COMMAND_FILE ]]; then
    echo ''
    echo "##### Create system-wide shell command for BitDust in $GLOBAL_COMMAND_FILE"
    ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
fi


echo ''
echo '##### Starting BitDust as a daemon process'
$GLOBAL_COMMAND_FILE daemon


echo ''
echo '##### DONE!!!'

exit 0
