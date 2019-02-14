#!/bin/bash

ROOT_DIR="$HOME/.bitdust"
SOURCE_DIR="${ROOT_DIR}/src"
GIT_PATH="/Applications/BitDust.app/Contents/Resources/app/app/scripts/git"
SOURCE_UI_DIR="${ROOT_DIR}/ui"
VENV_DIR="${ROOT_DIR}/venv"
PYTHON_BIN="${ROOT_DIR}/venv/bin/python"
SYS_PYTHON_BIN=`which python`
PIP_BIN="${ROOT_DIR}/venv/bin/pip"
BITDUST_PY="${SOURCE_DIR}/bitdust.py"
BITDUST_COMMAND_FILE="${ROOT_DIR}/bitdust"
GLOBAL_COMMAND_FILE="/usr/local/bin/bitdust"
GIT=""


if [[ "$1" == "stop" ]]; then
    echo ''
    echo '##### Stopping BitDust...'
    $PYTHON_BIN $BITDUST_PY stop
    exit 0;
fi


if [ -f $GIT_PATH ]; then
    GIT="$GIT_PATH"
else
    GIT="$(dirname $(pwd)/$0)/git"
fi

gitok=`which git`
pipok=`which pip`
pipuserok=`PATH="$HOME/Library/Python/2.7/bin:$PATH" which pip`
venvok=`which virtualenv`
venvuserok=`PATH="$HOME/Library/Python/2.7/bin:$PATH" which virtualenv`

if [[ ! $pipok ]]; then
    if [[ ! $pipuserok ]]; then
        echo ''
        echo '##### Installing PIP for current user'
        $SYS_PYTHON_BIN -m ensurepip -U -v --user
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
        $SYS_PYTHON_BIN -m pip install --upgrade virtualenv --user
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
    echo '##### Сloning the source code of BitDust project...'
    mkdir -p $SOURCE_DIR
    $GIT clone --depth=1 https://github.com/bitdust-io/public.git $SOURCE_DIR
else
    echo ''
    echo '##### BitDust source code already cloned locally'
fi


if [[ ! -e $SOURCE_UI_DIR ]]; then
    echo ''
    echo '##### Сloning the source code of BitDust UI...'
    mkdir -p $SOURCE_UI_DIR
    $GIT clone --depth=1 https://github.com/bitdust-io/web.git $SOURCE_UI_DIR
else
    cd $SOURCE_UI_DIR
    $GIT fetch
    $GIT reset --hard origin/master
    echo '##### Updating the source code of BitDust UI...'
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



echo '##### Starting BitDust as a daemon process'
$PYTHON_BIN $BITDUST_PY daemon


echo ''
echo '##### DONE!!!'

exit 0
