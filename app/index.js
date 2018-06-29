const { app, BrowserWindow } = require('electron');
const path = require('path')
const url = require('url')
const os = require('os')
const log = require('electron-log')
const ipc = require('electron').ipcMain

const { installBitdust } = require('./dependencies');

let win;

const uiDir = `${os.homedir()}/.bitdust/ui`

function createWindow() {
    win = new BrowserWindow({
        minWidth: 1024,
        minHeight: 576,
        title: 'BitDust',
        //titleBarStyle: 'hidden'
    });

    if (process.env.ELECTRON_ENV === 'debug') {
        win.loadURL('http://localhost:8080/');
    } else {
        win.loadURL(url.format({
            pathname: path.join(uiDir, 'dist/index.html'),
            protocol: 'file:',
            slashes: true
        }));
    }
    win.maximize()
    win.webContents.openDevTools()

    win.on('closed', () => {
        win = null
    });
}

function createSplashScreen() {
    const splashScreen = new BrowserWindow({
        width: 400, height: 241,
        center: true,
        frame: false, resizable: false, movable: false, minimizable: false, maximizable: false,
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
        await installBitdust()
        splashScreen.close()
        createWindow()
    } catch (error) {
        log.error(error);
    }
}


app.on('ready', init);

// Quit when all windows are closed.
app.on('window-all-closed', () => {
    // On macOS it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (process.platform !== 'darwin') {
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
