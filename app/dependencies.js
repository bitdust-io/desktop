const fs = require('fs')
const path = require('path')
const exec = require('child_process').exec

const deployCommand = fs.readFileSync(path.resolve(__dirname,'./scripts/deploy_osx.sh'), 'UTF-8')

const installBitdust = () => {
    return new Promise((resolve, reject) => {
        exec(deployCommand, (error, stdout, stderr) => {
            if (error) reject(error)
            resolve(stdout)
        })
    })
}

module.exports = {
    installBitdust
}
