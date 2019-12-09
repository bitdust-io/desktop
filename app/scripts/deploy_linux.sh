#!/bin/sh

ROOT_DIR="$HOME/.bitdust"
LOG_FILE="${ROOT_DIR}/venv.log"
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
    echo '##### Stopping BitDust'
    $PYTHON_BIN $BITDUST_PY stop
    echo ''
    echo 'DONE'
    exit 0;
fi


if [ "$1" = "restart" ]; then
    echo ''
    echo '##### Restarting BitDust'
    $PYTHON_BIN $BITDUST_PY restart
    echo ''
    echo 'DONE'
    exit 0;
fi


if [ ! -d $ROOT_DIR ]; then
    echo ''
    echo "##### Create BitDust Home folder"
    mkdir -p $ROOT_DIR
else
    echo ''
    echo "##### BitDust Home folder found locally"
fi


cd "$ROOT_DIR"


if [ ! -d $SOURCE_DIR ]; then
    echo ''
    echo "##### Downloading BitDust source code from Git repository"
    mkdir -p $SOURCE_DIR
    git clone --depth=1 https://github.com/bitdust-io/public.git $SOURCE_DIR
else
    echo ''
    echo "##### BitDust source files already cloned locally"
    cd "$SOURCE_DIR"
    echo ''
    echo "##### Updating BitDust source files from Git repository"
    git fetch --all
    echo ''
    echo "##### Refreshing BitDust source files"
    git reset --hard origin/master
    cd ..
fi


if [ ! -d $SOURCE_UI_DIR ]; then
    echo ''
    echo "##### Downloading BitDust UI source files from Git repository"
    mkdir -p $SOURCE_UI_DIR
    git clone --single-branch --branch gh-pages --depth=1 "git://github.com/bitdust-io/ui.git" "$SOURCE_UI_DIR"
else
    echo ''
    echo "##### BitDust UI source files already cloned locally"
    cd $SOURCE_UI_DIR
    echo ''
    echo "##### Updating BitDust UI source files from Git repository"
    git fetch
    echo ''
    echo "##### Refreshing BitDust UI source files"
    git reset --hard origin/gh-pages
    cd ..
fi


if [ ! -d $PIP_BIN ]; then
    echo ''
    echo "##### Preparing Python virtual environment"
    python $BITDUST_PY install  1>$LOG_FILE 2>$LOG_FILE
    ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
else
    # TODO: this is slow and can fail if user is offline...
    # this actually must be only executed when requirements.txt was changed
    echo ''
    echo "##### Updating Python virtual environment"
    $PIP_BIN install -U -r $SOURCE_DIR/requirements.txt  1>$LOG_FILE 2>$LOG_FILE
fi


if [ ! -f $GLOBAL_COMMAND_FILE ]; then
    echo ''
    echo "##### Create system-wide shell command"
    ln -s -f $BITDUST_COMMAND_FILE $GLOBAL_COMMAND_FILE
fi


echo ''
echo '##### Starting BitDust as a daemon process'
$GLOBAL_COMMAND_FILE daemon


echo ''
echo DONE'


exit 0

