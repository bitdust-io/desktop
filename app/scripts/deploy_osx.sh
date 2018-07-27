#!/bin/bash

ROOT_DIR="$HOME/.bitdust"
SOURCE_DIR="${ROOT_DIR}/src"
SOURCE_UI_DIR="${ROOT_DIR}/ui"
VENV_DIR="${ROOT_DIR}/venv"
PYTHON_BIN="${ROOT_DIR}/venv/bin/python"
PIP_BIN="${ROOT_DIR}/venv/bin/pip"
BITDUST_PY="${SOURCE_DIR}/bitdust.py"
BITDUST_COMMAND_FILE="${ROOT_DIR}/bitdust"
GLOBAL_COMMAND_FILE="/usr/local/bin/bitdust"


which -s brew
if [[ $? != 0 ]]; then
    echo ''
    echo '##### Installing Homebrew...'
    echo | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo ''
    echo '##### Homebrew already installed'
fi


gitok=`which git`
pythonok=`brew list | grep python`
pipok=`which pip`
pipuserok=`PATH="$HOME/Library/Python/2.7/bin:$PATH" which pip`
venvok=`which virtualenv`
venvuserok=`PATH="$HOME/Library/Python/2.7/bin:$PATH" which virtualenv`


if [[ ! $gitok ]]; then
    echo ''
    echo '##### Installing GIT...'
    brew install git
else
    echo ''
    echo '##### GIT already installed'
fi


if [[ ! $pythonok ]]; then
    echo ''
    echo '##### Installing Formula Python...'
    brew install python
else
    echo ''
    echo '##### Python already installed'
fi


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
    echo '##### Сloning the source code of BitDust project...'
    mkdir -p $SOURCE_DIR
    git clone --depth=1 https://github.com/bitdust-io/devel.git $SOURCE_DIR
    # git clone --depth=1 https://github.com/bitdust-io/public.git $SOURCE_DIR
else
    echo ''
    echo '##### BitDust source code already cloned locally'
fi


if [[ ! -e $SOURCE_UI_DIR ]]; then
    echo ''
    echo '##### Сloning the source code of BitDust UI...'
    mkdir -p $SOURCE_UI_DIR
    git clone --depth=1 https://github.com/bitdust-io/web.git $SOURCE_UI_DIR
else
    cd $SOURCE_UI_DIR
    git fetch
    git reset --hard origin/master
    echo '##### Updating the source code of BitDust UI...'
fi


if [[ ! -e $VENV_DIR ]]; then
    echo ''
    echo '##### Building BitDust virtual environment...'
    PATH="$HOME/Library/Python/2.7/bin:$PATH" python $BITDUST_PY install
    ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
    echo ''
    echo '##### System-wide shell command for BitDust created in ${GLOBAL_COMMAND_FILE}'
else
    echo ''
    echo '##### BitDust virtual environment already exist'
fi


echo ''
echo '##### Starting BitDust as a daemon process'
$PYTHON_BIN $BITDUST_PY daemon


echo ''
echo '##### DONE!!!'

