const fs = require('fs')
const path = require('path')
const exec = require('child_process').exec
const spawn = require('child_process').spawn
const ipc = require('electron').ipcMain
const log = require('electron-log')
const shellPath = require('shell-path');

const deployLinux = path.resolve(__dirname,'./scripts/deploy_linux.sh')
const deployMacOs = path.resolve(__dirname,'./scripts/deploy_osx.sh')
const deployWin = path.resolve(__dirname,'./scripts/deploy_win.bat')

let deployScript = '';

const installBitdust = () => {

    if (process.platform === 'linux') {
        deployScript = deployLinux;
    } else if (process.platform === 'darwin') {
        deployScript = deployMacOs;
    } else if (process.platform === 'win32') {
        deplyScript = deployWin;
    } else {
		log.error('Unknown platform');
		return;
	};

    return new Promise((resolve, reject) => {
    
		var options = {
		    env : process.env
		};
		options.env.PATH = shellPath.sync();

		log.debug('Running: ' + deplyScript);
        let childProcess = exec(deplyScript, options);

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

module.exports = {
    installBitdust
}
