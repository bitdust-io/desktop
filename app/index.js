const { app, BrowserWindow } = require('electron');
const path = require('path')
const url = require('url')
const os = require('os')
const log = require('electron-log')
const ipc = require('electron').ipcMain

const { installBitdust } = require('./dependencies');

let win;
let isStarting = true;

const uiDir = `${os.homedir()}/.bitdust/ui`

function createWindow() {
    win = new BrowserWindow({
        minWidth: 600,
        minHeight: 400,
        width: 1024,
        height: 768,
        title: 'BitDust',
		//devTools: false,
        //titleBarStyle: 'hidden'
    });

    if (process.env.ELECTRON_ENV === 'debug') {
        win.loadURL('http://localhost:8080/');
    } else {
		log.debug('Opening main UI page: ' + path.join(uiDir, 'dist/index.html'));
        win.loadURL(url.format({
            pathname: path.join(uiDir, 'dist/index.html'),
            protocol: 'file:',
            slashes: true
        }));
    }
    isStarting = false;
    //win.maximize()
    //win.webContents.openDevTools()

    win.on('closed', () => {
        win = null
    });
}

function sleep() {
    return new Promise((resolve, reject) => {
        setTimeout(resolve, 20000)
    })
}

function createSplashScreen() {
    const splashScreen = new BrowserWindow({
        width: 500, height: 350,
        center: true,
        frame: true,
        resizable: false, movable: false, minimizable: false, maximizable: false,
        alwaysOnTop: true, skipTaskbar: true,
    });
    splashScreen.loadURL(url.format({
        pathname: path.join(__dirname, './html/splash.html'),
        protocol: 'file:',
        slashes: true
    }));
    ipc.on('installationStep', (message) => {
        splashScreen.webContents.send('updateProgressBar', message)
    })

    return splashScreen
}


async function init() {
    try {
        const splashScreen = createSplashScreen()
		log.debug('Target platform: ' + process.platform);
        await installBitdust()
		//await sleep()
        splashScreen.close()
        createWindow()
    } catch (error) {
        isStarting = false
        log.error(error)
    }
}


app.on('ready', init);

// Quit when all windows are closed.
app.on('window-all-closed', () => {
    // On macOS it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (!isStarting) {
        app.quit()
    }
});

app.on('activate', () => {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (win === null) {
        createWindow()
    }
});
