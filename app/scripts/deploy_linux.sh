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


if [ "$1" = "stop" ]; then
    echo ''
    echo '##### Stopping BitDust...'
    $PYTHON_BIN $BITDUST_PY stop
    echo ''
    echo '##### DONE!!!'
    exit 0;
fi


if [ "$1" = "restart" ]; then
    echo ''
    echo '##### Restarting BitDust...'
    $PYTHON_BIN $BITDUST_PY restart
    echo ''
    echo '##### DONE!!!'
    exit 0;
fi


if [ ! -d $ROOT_DIR ]; then
    echo ''
    echo "##### Create BitDust Home folder at $ROOT_DIR"
    mkdir -p $ROOT_DIR
else
    echo ''
    echo "##### BitDust Home folder found at $ROOT_DIR"
fi


cd "$ROOT_DIR"


if [ ! -d $SOURCE_DIR ]; then
    echo ''
    echo "##### Сloning source code of BitDust project to $SOURCE_DIR"
    mkdir -p $SOURCE_DIR
    git clone --depth=1 https://github.com/bitdust-io/public.git $SOURCE_DIR
else
    echo ''
    echo "##### BitDust source code already cloned locally in $SOURCE_DIR"
    cd "$SOURCE_DIR"
    echo ''
    echo "##### Running 'git fetch' in $SOURCE_DIR"
    git fetch --all
    echo ''
    echo "##### Running 'git reset origin/master' in $SOURCE_DIR"
    git reset --hard origin/master
    cd ..
fi


if [ ! -d $SOURCE_UI_DIR ]; then
    echo ''
    echo "##### Сloning source code of BitDust UI in $SOURCE_UI_DIR"
    mkdir -p $SOURCE_UI_DIR
    git clone --depth=1 https://github.com/bitdust-io/ui.git "$SOURCE_UI_DIR"
else
    echo ''
    echo "##### BitDust UI source code already cloned locally in $SOURCE_UI_DIR"
    cd $SOURCE_UI_DIR
    echo ''
    echo "##### Running 'git fetch' in $SOURCE_UI_DIR"
    git fetch
    echo ''
    echo "##### Running 'git reset --hard origin/master' in $SOURCE_UI_DIR"
    git reset --hard origin/master
    cd ..
fi


if [ ! -d $PIP_BIN ]; then
    echo ''
    echo "##### Installing BitDust, virtual environment location is $VENV_DIR"
    python $BITDUST_PY install
    ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
else
    # TODO: this is slow and can fail if user is offline...
    # this actually must be only executed when requirements.txt was changed
    echo ''
    echo "##### Updating BitDust virtual environment in $VENV_DIR"
    $PIP_BIN install -U -r $SOURCE_DIR/requirements.txt
fi


if [ ! -f $GLOBAL_COMMAND_FILE ]; then
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

