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
    echo ''
    echo '##### Installing PIP for current user'
    pip install --upgrade --user
    pip install --upgrade pip --user

    echo ''
    echo '##### Installing virtualenv for current user'
    pip install virtualenv --user
else
    echo ''
    echo '##### PIP already installed'
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
    # virtualenv -p python2.7 $VENV_DIR
    virtualenv $VENV_DIR
    echo ''
    echo '##### Created fresh BitDust virtual environment'
else
    echo ''
    echo '##### BitDust virtual environment already exist'
fi


$PIP_BIN install --index-url=https://pypi.python.org/simple/ -r $SOURCE_DIR/requirements.txt


# if [[ ! -e $VENV_DIR ]]; then
#     echo ''
#     echo '##### Building BitDust virtual environment...'
#     python $BITDUST_PY install
    
#     ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
#     echo ''
#     echo '##### System-wide shell command for BitDust created in ${GLOBAL_COMMAND_FILE}'
# else
#     echo ''
#     echo '##### BitDust virtual environment already exist'
# fi


echo ''
echo '##### Starting BitDust as a daemon pocess'
# $GLOBAL_COMMAND_FILE daemon
$PYTHON_BIN $BITDUST_PY daemon


echo ''
echo '##### DONE!!!'

