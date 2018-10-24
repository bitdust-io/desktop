const url = require('url')
const os = require('os')
const path = require('path')

const ipc = require('electron').ipcMain

const { BrowserWindow } = require('electron')
const log = require('electron-log')

const uiDir = `${os.homedir()}/.bitdust/ui`

function createSplashScreen() {
	log.warn('createSplashScreen')
    let splashScreen = new BrowserWindow({
        width: 500,
        height: 350,
        center: true,
        frame: false,
        resizable: false,
        movable: true,
        minimizable: false,
        maximizable: false,
        alwaysOnTop: true,
        skipTaskbar: true,
    })
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
        minHeight: 400,
        width: 1024,
        height: 768,
        title: 'BitDust',
		//devTools: false,
        //titleBarStyle: 'hidden'
    })

    if (process.env.ELECTRON_ENV === 'debug') {
        win.loadURL('http://localhost:8080/')
    } else {
		log.warn('Opening main UI page: ' + path.join(uiDir, 'dist/index.html'))
        win.loadURL(url.format({
            pathname: path.join(uiDir, 'dist/index.html'),
            protocol: 'file:',
            slashes: true
        }))
    }
	return win
}

module.exports = {
    createMainWindow,
    createSplashScreen
}