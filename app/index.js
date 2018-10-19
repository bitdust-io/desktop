
const { app, dialog, Tray, Menu } = require('electron');

const ipc = require('electron').ipcMain
const exec = require('child_process').exec

const request = require('request')
const log = require('electron-log')
const path = require('path')

const setup = require('./setup')
const ui = require('./ui')


let win;
let isStarting = true;
let showExitPrompt = true;



//function sleep() {
//    return new Promise((resolve, reject) => {
//        setTimeout(resolve, 200000)
//    })
//}
//await sleep()


function showWindow() {
    if (win) {
        if (!win.isVisible()) {
            win.show()
        }
    } else {
        win = ui.createMainWindow()
        win.on('closed', () => {
            win = null
        })
    } 
}

function showDialogOnExit(e, app) {

    if (showExitPrompt) {
        e.preventDefault();

        dialog.showMessageBox({
            type: 'question',
            buttons: ['Keep running in the background', 'Stop BitDust', 'Cancel'],
            defaultId: 0,
            cancelId: 2,
            title: 'Confirm',
            message: 'Do you want to run BitDust in the background or stop it completely?'
        }, (response) => {
            if (response === 0) {
				if (win && win.isVisible()) {
					win.hide()
				}
			} else if (response === 1) {
				setup.stopBitDust()
                showExitPrompt = false
                app.quit()
			}
        })
    }
}


function runHealthCheck() {
    setTimeout(() => {
        request('http://localhost:8180/process/health/v1', async (err, res, body) => {
            if (err) {
                await setup.runBitDust()
            }
            runHealthCheck()
        });
    }, 10000)
}

async function init() {
    try {
        const splashScreen = ui.createSplashScreen()
        await setup.runBitDust()
        log.warn('installBitDust DONE')
        splashScreen.close()
		log.warn('init DONE : createWindow')
        win = ui.createMainWindow()
		win.on('closed', () => {
			win = null
		})
        isStarting = false
        runHealthCheck()
    } catch (error) {
        isStarting = false
        log.error(error)
    }
}



ipc.on('restart', setup.runBitDust)

app.on('ready', () => {
	if (process.platform === 'win32') {
		const iconPath = path.join(__dirname, '..', 'build_resources', 'bitdust2.ico')
		tray = new Tray(iconPath)
		tray.setToolTip('BitDust')
		tray.on('click', showWindow)
	}
    init()
});

// Quit when all windows are closed.
app.on('window-all-closed', () => {
    if (isStarting === false) {
		log.warn('window-all-closed : app.quit')
		app.hide()
    }
});

// Mac OS only
app.on('activate', () => showWindow);

app.on('before-quit', (e) => showDialogOnExit(e, app));