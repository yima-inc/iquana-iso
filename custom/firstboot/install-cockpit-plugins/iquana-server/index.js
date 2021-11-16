const bindAddress = document.getElementById('bindAddress')
const nodeName = document.getElementById('nodeName')
const nodeExternalIp = document.getElementById('nodeExternalIp')

const deployButton = document.getElementById('deployButton')
const undeployButton = document.getElementById('undeployButton')

const kubeconfig = document.getElementById('kubeconfig')
const token = document.getElementById('token')
const reloadButton = document.getElementById('reloadButton')
const copyKubeconfig = document.getElementById('copyKubeconfig')
const copyKubeconfigResult = document.getElementById('copyKubeconfigResult')
const copyToken = document.getElementById('copyToken')
const copyTokenResult = document.getElementById('copyTokenResult')

function deploy() {
  deployButton.disabled = true

  const config = `K3S_NODE_NAME=${nodeName.value}
FLANNEL_IFACE=eth1
NODE_LABELS=role=server
BIND_ADDRESS=${bindAddress.value}
NODE_EXTERNAL_IP=${nodeExternalIp.value}
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
  cockpit.spawn(['/usr/local/bin/iquana-server.sh'], {superuser: 'iquana'})
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

  on_reload_kubeconfig()
}

function on_reload_kubeconfig() {
  cockpit.file('/etc/rancher/k3s/k3s.yaml', {superuser: 'iquana'})
    .read()
    .then((content, tag) => {
      if (content) {
        kubeconfig.innerHTML = content
        on_reload_token()

        return
      }

      on_reload_update(false)
    })
    .catch(error => {
      on_reload_update(false)
    })
}

function on_reload_token() {
  cockpit.file('/var/lib/rancher/k3s/server/node-token', {superuser: 'iquana'})
    .read()
    .then((content, tag) => {
      if (content) {
        token.innerHTML = content
        on_reload_update(true)

        return
      }

      on_reload_update(false)
    })
    .catch(error => {
      on_reload_update(false)
    })
}

function on_reload_update(deployed) {
  deployButton.disabled = !!deployed
  undeployButton.disabled = false
  reloadButton.disabled = false
  copyKubeconfig.disabled = !deployed
  copyToken.disabled = !deployed

  if (!deployed) {
    kubeconfig.innerHTML = '(not available)'
    token.innerHTML = '(not available)'
  }
}

function copy_kubeconfig() {
  navigator.clipboard.writeText(kubeconfig.innerHTML)
    .then(
      () => {
        copyKubeconfigResult.innerHTML = 'Copied to Clipboard!'
        setTimeout(() => {copyKubeconfigResult.innerHTML = ''}, 3 * 1000)
      },
      () => {
        copyKubeconfigResult.innerHTML = 'Failed'
        setTimeout(() => {copyKubeconfigResult.innerHTML = ''}, 3 * 1000)
      }
    )
}

function copy_token() {
  navigator.clipboard.writeText(token.innerHTML)
    .then(
      () => {
        copyTokenResult.innerHTML = 'Copied to Clipboard!'
        setTimeout(() => {copyTokenResult.innerHTML = ''}, 3 * 1000)
      },
      () => {
        copyTokenResult.innerHTML = 'Failed'
        setTimeout(() => {copyTokenResult.innerHTML = ''}, 3 * 1000)
      }
    )
}

deployButton.addEventListener('click', deploy)
undeployButton.addEventListener('click', undeploy)
reloadButton.addEventListener('click', on_reload)
copyKubeconfig.addEventListener('click', copy_kubeconfig)
copyToken.addEventListener('click', copy_token)

on_reload()

// Send a 'init' message.  This tells integration tests that we are ready to go
cockpit.transport.wait(function() {});
