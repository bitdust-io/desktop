const { app, BrowserWindow } = require('electron');
const path = require('path')
const url = require('url')
const os = require('os')
const log = require('electron-log')
const ipc = require('electron').ipcMain
const request = require('request')
const { exec } = require('child_process')

const { installBitDust } = require('./dependencies');

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
		log.warn('Opening main UI page: ' + path.join(uiDir, 'dist/index.html'));
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

//function sleep() {
//    return new Promise((resolve, reject) => {
//        setTimeout(resolve, 200000)
//    })
//}

function createSplashScreen() {
	log.warn('createSplashScreen')
    const splashScreen = new BrowserWindow({
        width: 500, height: 350,
        center: true,
        frame: true,
        resizable: false, movable: true, minimizable: false, maximizable: false,
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


function runHealthCheck() {
    request('http://localhost:8180/process/health/v1', (err, res, body) => {
        if (err) exec("bitdust start")
    });
}

async function init() {
    try {
        const splashScreen = createSplashScreen()
		log.warn('Target platform: ' + process.platform)
        await installBitDust()
		log.warn('installBitDust DONE')
		//await sleep()
        splashScreen.close()
		log.warn('init DONE : createWindow')
        createWindow()
        setInterval(runHealthCheck, 10000)
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
		log.warn('window-all-closed : app.quit')
        app.quit()
    }
});

app.on('activate', () => {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (win === null) {
		log.warn('activate : createWindow')
        createWindow()
    }
});
