
const { app, dialog, Tray, Menu } = require('electron');

const ipc = require('electron').ipcMain
const exec = require('child_process').exec

const request = require('request')
const log = require('electron-log')


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




function showDialogOnExit(e, app) {
    if (showExitPrompt) {
        e.preventDefault();

        dialog.showMessageBox({
            type: 'question',
            buttons: ['Yes', 'No'],
            defaultId: 1,
            cancelId: 1,
            title: 'Confirm',
            message: 'Do you want to close BitDust and stop all related processes?'
        }, (response) => {
            if (response === 0) {
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
        ui.createMainWindow(win)
        isStarting = false
        // runHealthCheck()
    } catch (error) {
        isStarting = false
        log.error(error)
    }
}
























ipc.on('restart', setup.runBitDust)

app.on('ready', () => {
    // tray = new Tray('/Users/agrishun/dev/bitdust/desktop/icon.png')
    // const contextMenu = Menu.buildFromTemplate([
    //   {label: 'Item1', type: 'radio'},
    //   {label: 'Item2', type: 'radio'},
    //   {label: 'Item3', type: 'radio', checked: true},
    //   {label: 'Item4', type: 'radio'}
    // ])
    // tray.setToolTip('BitDust')
    // tray.setContextMenu(contextMenu)
    init()
});

// Quit when all windows are closed.
app.on('window-all-closed', () => {
    // On macOS it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    // if (!isStarting) {
	// 	log.warn('window-all-closed : app.quit')
    //     app.quit()
    // }
});

app.on('activate', () => {
    if (win === null) {
		log.warn('activate : createWindow')
        ui.createMainWindow()
    }
});

app.on('before-quit', (e) => showDialogOnExit(e, app));