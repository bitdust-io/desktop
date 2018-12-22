#!/bin/sh


ROOT_DIR="$HOME/.bitdust"
SOURCE_DIR="${ROOT_DIR}/src"
SOURCE_UI_DIR="${ROOT_DIR}/ui"
VENV_DIR="${ROOT_DIR}/venv"
PYTHON_BIN="${ROOT_DIR}/venv/bin/python"
PIP_BIN="${ROOT_DIR}/venv/bin/pip"
BITDUST_PY="${SOURCE_DIR}/bitdust.py"
BITDUST_COMMAND_FILE="${ROOT_DIR}/bitdust"
GLOBAL_COMMAND_FILE="/usr/local/bin/bitdust"


if [ $1 == "stop" ]; then
    $PYTHON_BIN $BITDUST_PY stop
    exit 0;
else


if [ ! -d $SOURCE_DIR ]; then
    echo ''
    echo '##### Сloning the source code of BitDust project...'
    mkdir -p $SOURCE_DIR
    git clone --depth=1 https://github.com/bitdust-io/public.git $SOURCE_DIR
else
    echo ''
    echo '##### BitDust source code already cloned locally'
fi


if [ ! -d $SOURCE_UI_DIR ]; then
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


if [ ! -d $VENV_DIR ]; then
    echo ''
    echo '##### Building BitDust virtual environment...'
    python $BITDUST_PY install
    ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
    echo ''
    echo '##### System-wide shell command "bitdust" was created'
else
    echo ''
    echo '##### BitDust virtual environment already exist, updating...'
    $PIP_BIN install -U -r $SOURCE_DIR/requirements.txt
fi


echo ''
echo '##### Starting BitDust as a daemon process'
$GLOBAL_COMMAND_FILE daemon


echo ''
echo '##### DONE!!!'

exit 0

