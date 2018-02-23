const { app, BrowserWindow } = require('electron');
const path = require('path');
const url = require('url');

const { sudoInstallGit, installBitdust, checkIfGitInstalled } = require('./dependencies')

let win;

function createWindow() {
    win = new BrowserWindow({width: 800, height: 600});

    win.loadURL(url.format({
        pathname: path.join(__dirname, '../web/index.html'),
        protocol: 'file:',
        slashes: true
    }));

    win.webContents.openDevTools();

    win.on('closed', () => {
        win = null
    });
}




async function installDependencies() {
    try {
        await checkIfGitInstalled()
    } catch (error) {
        try {
            const res = await sudoInstallGit()
        } catch (error) {
            console.log(error)
        }
    }
    try {
        const res = await installBitdust()
        console.log(res)
    } catch (error) {
        console.log(error)
    }
}

async function init() {
    try {
        await installDependencies()
    } catch (error) {
        console.log(error)
    }
    try {
        await createWindow()
    } catch (error) {
        console.log(error)
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