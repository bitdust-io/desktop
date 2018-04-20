const path = require('path')
const exec = require('child_process').exec
const sudo = require('sudo-prompt')

const pathPrefix = process.env.ELECTRON_ENV === 'production' ? process.resourcesPath : ''


const installGitScript = path.resolve(pathPrefix, './bash/install_git_osx.sh')
const installLibsScript = path.resolve(pathPrefix, './bash/deploy_osx.sh')

const options = {
    name: 'BitDust'
}


const sudoInstallGit = () => {
    return new Promise((resolve, reject) => {
        sudo.exec(`sh ${installGitScript}`, options, (error, stdout, stderr) => {
            if (error) reject(error)
            resolve(stdout)
        })
    })
}

const installBitdust = () => {
    return new Promise((resolve, reject) => {
        exec(installLibsScript, (error, stdout, stderr) => {
            if (error) reject(error)
            resolve(stdout)
        })
    })
}

const checkIfGitInstalled = () => {
    return new Promise((resolve, reject) => {
      exec('which git', (error, stdout, stderr) => {
        if (error) reject(error)
        resolve()
      })  
    })
}

module.exports = {
    installBitdust,
    sudoInstallGit,
    checkIfGitInstalled
}
