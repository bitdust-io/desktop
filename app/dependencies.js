const fs = require('fs')
const path = require('path')
const exec = require('child_process').exec
const ipc = require('electron').ipcMain

const deployMacOs = path.resolve(__dirname,'./scripts/deploy_osx.sh')
const deployWin = path.resolve(__dirname,'./scripts/deploy_win.bat')

const installBitdust = () => {
    let deployScript = process.platform === 'darwin' ? deployMacOs : deployWin
    return new Promise((resolve, reject) => {
        let childProcess = exec(deployScript)
        childProcess.stdout.on('data', (data) => {
            const message = data.toString()
            ipc.emit('installationStep', message)
        });
        childProcess.stdout.on('error', reject);
        childProcess.stdout.on('close', resolve);
    })
}

module.exports = {
    installBitdust
}
