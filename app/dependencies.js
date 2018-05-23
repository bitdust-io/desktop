const fs = require('fs')
const path = require('path')
const exec = require('child_process').exec

const deployMacOs = fs.readFileSync(path.resolve(__dirname,'./scripts/deploy_osx.sh'), 'UTF-8')
const deployWin = fs.readFileSync(path.resolve(__dirname,'./scripts/deploy_win.bat'), 'UTF-8')

const installBitdust = () => {
    let deployScript = process.platform === 'darwin' ? deployMacOs : deployWin
    return new Promise((resolve, reject) => {
        exec(deployScript, (error, stdout, stderr) => {
            if (error) reject(error)
            resolve(stdout)
        })
    })
}

module.exports = {
    installBitdust
}
