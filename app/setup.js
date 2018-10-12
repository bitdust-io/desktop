const fs = require('fs')
const path = require('path')
const exec = require('child_process').exec
const ipc = require('electron').ipcMain
const log = require('electron-log')
const shellPath = require('shell-path');


var options = { env : process.env };
options.env.PATH = shellPath.sync();


const getEnvironmentScript = (platform) => {
    switch(platform) {
        case 'linux':
            return path.resolve(__dirname,'./scripts/deploy_linux.sh')
        case 'darwin':
            return path.resolve(__dirname,'./scripts/deploy_osx.sh')
        case 'win32':
            return path.resolve(__dirname,'./scripts/deploy_win.bat')
        default:
            throw new Error('Unknown platform')
    }
}

const runBitDust = () => {
    log.debug('Target platform: ' + process.platform)
    const deployScript = getEnvironmentScript(process.platform)
    log.debug('Running: ' + deployScript);
    return new Promise((resolve, reject) => {
		const childProcess = exec(deployScript, options);

        childProcess.stdout.on('data', (data) => {
            const message = data.toString()
            ipc.emit('installationStep', message)
            log.warn(message)
        });

        childProcess.stderr.on('data', (data) => {
            const errmessage = data.toString()
            ipc.emit('installationStep', errmessage)
            log.warn(errmessage)
        });

        childProcess.stdout.on('error', reject);
        childProcess.stdout.on('close', resolve);
    })
}

const stopBitDust = () => {
    log.debug('Stopping bitdust');
    const childProcess = exec('bitdust stop', options);
}

module.exports = {
    runBitDust,
    stopBitDust
}
