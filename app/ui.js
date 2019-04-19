const url = require('url')
const os = require('os')
const path = require('path')

const ipc = require('electron').ipcMain

const {BrowserWindow, Menu} = require('electron')
const log = require('electron-log')

const setup = require('./setup')

const uiDir = `${os.homedir()}/.bitdust/ui`

function createSplashScreen() {
    log.warn('createSplashScreen')
    let splashScreen = new BrowserWindow({
        width: 800,
        height: 600,
        center: true,
        frame: true,
        resizable: false,
        movable: true,
        minimizable: true,
        maximizable: false,
        alwaysOnTop: false,
        skipTaskbar: true
    })
    splashScreen.setMenu(null);
    splashScreen.loadURL(url.format({
        pathname: path.join(__dirname, './html/splash.html'),
        protocol: 'file:',
        slashes: true
    }))
    ipc.on('installationStep', (message) => {
        splashScreen.webContents.send('updateProgressBar', message)
    })
    splashScreen.on('closed', () => {
        ipc.removeAllListeners('installationStep')
    })
    return splashScreen
}

function createMainWindow() {
    const win = new BrowserWindow({
        minWidth: 600,
        minHeight: 480,
        width: 800,
        height: 600,
        title: 'BitDust'
        //devTools: true
    });

    const menu = Menu.buildFromTemplate([{
        label: 'BitDust',
        submenu: [{
            label:'Restart',
            click() {
                try {
                    setup.restartBitDust()
                    log.warn('restart BitDust DONE')
                } catch (error) {
                    log.error(error)
                }
            }
        }]
    }])
    Menu.setApplicationMenu(menu);

    if (process.env.ELECTRON_ENV === 'debug') {
        win.loadURL('http://localhost:8080/')
    } else {
        log.warn('Opening main UI page: ' + path.join(uiDir, 'dist/index.html'))
        win.loadFile(path.join(uiDir, 'dist/index.html'))
    }
    return win
}

module.exports = {
    createMainWindow,
    createSplashScreen
}
