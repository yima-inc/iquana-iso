const nodeName = document.getElementById('nodeName')
const serverUrl = document.getElementById('serverUrl')
const serverToken = document.getElementById('serverToken')

const deployButton = document.getElementById('deployButton')
const undeployButton = document.getElementById('undeployButton')

const reloadButton = document.getElementById('reloadButton')
const copyKubeconfig = document.getElementById('copyKubeconfig')
const copyToken = document.getElementById('copyToken')

function deploy() {
  deployButton.disabled = true

  const config = `K3S_NODE_NAME=${nodeName.value}
FLANNEL_IFACE=eth1
NODE_LABELS=role=agent
K3S_URL=${serverUrl.value}
K3S_TOKEN=${serverToken.value}
`

  cockpit.file('/etc/default/iquana', {superuser: 'iquana'})
    .replace(config)
    .then(() => {
      deploy_spawn()
    })
    .catch((err) => {
      alert(err)
      on_reload()
    })
}

function deploy_spawn() {
  deployButton.disabled = true

  cockpit.spawn(['/usr/local/bin/iquana-agent.sh'], {superuser: 'iquana'})
    .then(() => {
      setTimeout(on_reload, 60 * 1000)
    })
    .catch((err, data) => {
      alert(`${err}\n${data}`)
      on_reload()
    })
}

function undeploy() {
  undeployButton.disabled = true

  cockpit.spawn(['/usr/local/bin/iquana-reset.sh'], {superuser: 'iquana'})
    .then(() => on_reload())
    .catch((err) => {
      alert(err)
      on_reload()
    })
}

function on_reload() {
  reloadButton.disabled = true

  cockpit.file('/usr/local/bin/k3s-agent-uninstall.sh')
    .read()
    .then((content) => {
      if (content) {
        on_reload_update(true)
      }
      else {
        on_reload_update(false)
      }
    })
    .catch((err) => {
      on_reload_update(false)
    })
}

function on_reload_update(deployed) {
  deployButton.disabled = !!deployed
  undeployButton.disabled = false
  reloadButton.disabled = false
}

deployButton.addEventListener('click', deploy)
undeployButton.addEventListener('click', undeploy)
reloadButton.addEventListener('click', on_reload)

on_reload()

// Send a 'init' message.  This tells integration tests that we are ready to go
cockpit.transport.wait(function() {});
