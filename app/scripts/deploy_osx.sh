#!/bin/bash


ROOT_DIR="$HOME/.bitdust"
SOURCE_DIR="${ROOT_DIR}/src"
SOURCE_UI_DIR="${ROOT_DIR}/ui"
VENV_DIR="${ROOT_DIR}/venv"
PYTHON_BIN="${ROOT_DIR}/venv/bin/python"
GIT_BIN="${ROOT_DIR}/git/bin/git"
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


if [[ ! -e $ROOT_DIR ]]; then
    echo ''
    echo "##### Create BitDust Home folder at $ROOT_DIR"
    mkdir -p $ROOT_DIR
fi


if [[ ! -f $GIT_BIN ]]; then
    echo ''
    echo "##### Copy GIT binariy from distribution to ${GIT_BIN}"
    mkdir -p "${ROOT_DIR}/git/bin/"
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    cp "${CURRENT_DIR}/../../build_resources/macos/git" "$ROOT_DIR/git/bin/"
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


cd $ROOT_DIR


if [[ ! -e $SOURCE_DIR ]]; then
    echo ''
    echo "##### Сloning the source code of BitDust project to $SOURCE_DIR"
    mkdir -p $SOURCE_DIR
    $GIT_BIN clone --depth=1 "git://github.com/bitdust-io/public.git" "$SOURCE_DIR"
else
    echo ''
    echo '##### BitDust source code already cloned locally, updating...'
    cd $SOURCE_DIR
    $GIT_BIN fetch --all
    $GIT_BIN reset --hard origin/master
    cd ..
fi


if [[ ! -e $SOURCE_UI_DIR ]]; then
    echo ''
    echo '##### Сloning the source code of BitDust UI...'
    mkdir -p $SOURCE_UI_DIR
    $GIT_BIN clone --depth=1 "git://github.com/bitdust-io/web.git" $SOURCE_UI_DIR
else
    echo ''
    echo '##### Updating the source code of BitDust UI...'
    cd $SOURCE_UI_DIR
    $GIT_BIN fetch --all
    $GIT_BIN reset --hard origin/master
    cd ..
fi


if [[ ! -e $VENV_DIR ]]; then
    echo ''
    echo '##### Building BitDust virtual environment...'
    PATH="$HOME/Library/Python/2.7/bin:$PATH" python $BITDUST_PY install
    ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
    echo ''
    echo '##### System-wide shell command for BitDust created'
else
    echo ''
    echo '##### BitDust virtual environment already exist, updating...'
    $PIP_BIN install -U -r $SOURCE_DIR/requirements.txt
fi


echo ''
echo '##### Starting BitDust as a daemon process'
$PYTHON_BIN $BITDUST_PY daemon


echo ''
echo '##### DONE!!!'

exit 0
